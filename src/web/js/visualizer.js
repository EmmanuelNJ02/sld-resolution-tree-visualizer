"use strict";

const fileInput = document.querySelector("#json-file");
const exampleSelect = document.querySelector("#example-select");
const loadExampleButton = document.querySelector("#load-example");
const loadMessage = document.querySelector("#load-message");
const treeSection = document.querySelector("#tree-section");
const treeTitle = document.querySelector("#tree-title");
const treeSummary = document.querySelector("#tree-summary");
const treeRoot = document.querySelector("#tree-root");
const treeCanvas = document.querySelector("#tree-canvas");
const treeConnections = document.querySelector("#tree-connections");
const nodeDetails = document.querySelector("#node-details");

const nodeWidth = 290;
const horizontalGap = 32;
const verticalGap = 48;
const svgNamespace = "http://www.w3.org/2000/svg";

const statusLabels = {
  success: "Éxito",
  failure: "Fallo",
  cutoff: "Límite alcanzado"
};

fileInput.addEventListener("change", async () => {
  const file = fileInput.files && fileInput.files[0];
  if (!file) return;

  try {
    const data = JSON.parse(await file.text());
    renderTree(data);
    setMessage(`Archivo cargado: ${file.name}`);
  } catch (error) {
    setMessage(error instanceof SyntaxError
      ? "No se pudo leer el archivo: el contenido no es JSON válido."
      : error.message, true);
  } finally {
    fileInput.value = "";
  }
});

loadExampleButton.addEventListener("click", async () => {
  const example = exampleSelect.value;
  if (!example) {
    setMessage("Selecciona un ejemplo antes de cargarlo.", true);
    return;
  }

  try {
    const response = await fetch(`../../examples/json/${encodeURIComponent(example)}.json`);
    if (!response.ok) {
      throw new Error(`No se pudo cargar el ejemplo (HTTP ${response.status}).`);
    }
    renderTree(await response.json());
    setMessage(`Ejemplo cargado: ${example}.json`);
  } catch (error) {
    setMessage(`${error.message} Si abriste la página como archivo, inicia un servidor local o carga el JSON manualmente.`, true);
  }
});

function setMessage(message, isError = false) {
  loadMessage.textContent = message;
  loadMessage.dataset.kind = isError ? "error" : "info";
}

function validateTree(data) {
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    throw new Error("El archivo debe contener un objeto JSON.");
  }
  if (typeof data.query !== "string" || !Number.isInteger(data.maxDepth) || data.maxDepth < 0 ||
      !Array.isArray(data.nodes) || data.nodes.length === 0 || !Array.isArray(data.answers)) {
    throw new Error("El JSON no cumple el formato de árbol SLD esperado.");
  }

  const nodesById = new Map();
  for (const node of data.nodes) {
    if (!node || typeof node.id !== "string" || node.id.length === 0 ||
        (node.parent !== null && typeof node.parent !== "string") ||
        !Number.isInteger(node.depth) || node.depth < 0 ||
        typeof node.goal !== "string" ||
        (node.clause !== null && typeof node.clause !== "string") ||
        !Array.isArray(node.pending) || !node.pending.every(value => typeof value === "string") ||
        !Array.isArray(node.bindings) ||
        !node.bindings.every(binding => binding && typeof binding.var === "string" &&
          typeof binding.value === "string") ||
        !Object.prototype.hasOwnProperty.call(statusLabels, node.status) ||
        !Array.isArray(node.children) || !node.children.every(id => typeof id === "string")) {
      throw new Error("Uno o más nodos tienen campos inválidos.");
    }
    if (nodesById.has(node.id)) throw new Error(`El identificador de nodo ${node.id} está repetido.`);
    nodesById.set(node.id, node);
  }

  const roots = data.nodes.filter(node => node.parent === null);
  if (roots.length !== 1 || roots[0] !== data.nodes[0]) {
    throw new Error("El árbol debe tener una única raíz, ubicada al inicio de nodes.");
  }

  for (const node of data.nodes) {
    if (node.parent !== null) {
      const parent = nodesById.get(node.parent);
      if (!parent || !parent.children.includes(node.id)) {
        throw new Error(`La relación padre-hijo de ${node.id} no es válida.`);
      }
    }
    for (const childId of node.children) {
      const child = nodesById.get(childId);
      if (!child || child.parent !== node.id) {
        throw new Error(`La conexión de ${node.id} hacia ${childId} no es válida.`);
      }
    }
  }

  for (const answer of data.answers) {
    const node = answer && nodesById.get(answer.node);
    if (!node || node.status !== "success" || !Array.isArray(answer.bindings) ||
        !answer.bindings.every(binding => binding && typeof binding.var === "string" &&
          typeof binding.value === "string")) {
      throw new Error("Una respuesta apunta a un nodo inexistente o no exitoso.");
    }
  }

  const visited = new Set();
  function visit(node) {
    if (visited.has(node.id)) throw new Error("El árbol contiene una conexión circular.");
    visited.add(node.id);
    for (const childId of node.children) visit(nodesById.get(childId));
  }
  visit(roots[0]);
  if (visited.size !== data.nodes.length) {
    throw new Error("Hay nodos que no pertenecen a la raíz del árbol.");
  }

  return { root: roots[0], nodesById };
}

function renderTree(data) {
  const { root, nodesById } = validateTree(data);
  const answerIds = new Set(data.answers.map(answer => answer.node));

  treeSection.hidden = false;
  treeTitle.textContent = data.query;
  treeSummary.replaceChildren(
    summaryItem("Profundidad máxima", data.maxDepth),
    summaryItem("Nodos", data.nodes.length),
    summaryItem("Soluciones", data.answers.length)
  );
  const positions = calculateNodePositions(root, nodesById);
  const width = Math.max(
    positions.width,
    treeViewportWidth()
  );
  const horizontalOffset = (width - positions.width) / 2;
  treeCanvas.style.width = `${width}px`;
  treeCanvas.style.height = "1px";
  treeConnections.replaceChildren();

  const elements = new Map();
  const fragment = document.createDocumentFragment();
  for (const node of data.nodes) {
    const item = createNodeElement(node, answerIds);
    item.style.left = `${horizontalOffset + positions.centers.get(node.id) - nodeWidth / 2}px`;
    item.style.top = "0";
    elements.set(node.id, item);
    fragment.append(item);
  }
  treeRoot.replaceChildren(fragment);

  const heightsByDepth = new Map();
  for (const [id, item] of elements) {
    const depth = nodesById.get(id).depth;
    const height = item.querySelector(".node-card").getBoundingClientRect().height;
    heightsByDepth.set(depth, Math.max(heightsByDepth.get(depth) || 0, height));
  }

  const maxDepth = Math.max(...data.nodes.map(node => node.depth));
  const topsByDepth = new Map([[0, 0]]);
  for (let depth = 1; depth <= maxDepth; depth += 1) {
    topsByDepth.set(depth, topsByDepth.get(depth - 1) +
      heightsByDepth.get(depth - 1) + verticalGap);
  }

  for (const node of data.nodes) {
    elements.get(node.id).style.top = `${topsByDepth.get(node.depth)}px`;
  }

  const height = topsByDepth.get(maxDepth) + heightsByDepth.get(maxDepth);
  treeCanvas.style.height = `${height}px`;
  treeConnections.setAttribute("width", String(width));
  treeConnections.setAttribute("height", String(height));
  treeConnections.setAttribute("viewBox", `0 0 ${width} ${height}`);

  for (const node of data.nodes) {
    if (node.children.length === 0) continue;
    const parentCenter = horizontalOffset + positions.centers.get(node.id);
    const parentBottom = topsByDepth.get(node.depth) + elements.get(node.id)
      .querySelector(".node-card").getBoundingClientRect().height;
    const childTop = topsByDepth.get(node.depth + 1);
    const branchY = parentBottom + (childTop - parentBottom) / 2;
    const childCenters = node.children.map(id =>
      horizontalOffset + positions.centers.get(id));

    addConnection(parentCenter, parentBottom, parentCenter, branchY);
    if (childCenters.length > 1) {
      addConnection(Math.min(...childCenters), branchY, Math.max(...childCenters), branchY);
    }
    for (const childCenter of childCenters) {
      addConnection(childCenter, branchY, childCenter, childTop);
    }
  }

  showNodeDetails(root);
}

function treeViewportWidth() {
  const padding = window.matchMedia("(max-width: 720px)").matches ? 16 : 48;
  return Math.max(nodeWidth, treeCanvas.parentElement.clientWidth - padding);
}

function calculateNodePositions(root, nodesById) {
  const centers = new Map();
  let nextLeaf = 0;

  function place(node) {
    if (node.children.length === 0) {
      const center = nodeWidth / 2 + nextLeaf * (nodeWidth + horizontalGap);
      nextLeaf += 1;
      centers.set(node.id, center);
      return center;
    }

    const childCenters = node.children.map(childId => place(nodesById.get(childId)));
    const center = (childCenters[0] + childCenters[childCenters.length - 1]) / 2;
    centers.set(node.id, center);
    return center;
  }

  place(root);
  const width = Math.max(nodeWidth, nextLeaf * nodeWidth + (nextLeaf - 1) * horizontalGap);
  return { centers, width };
}

function addConnection(x1, y1, x2, y2) {
  const line = document.createElementNS(svgNamespace, "line");
  line.setAttribute("x1", String(x1));
  line.setAttribute("y1", String(y1));
  line.setAttribute("x2", String(x2));
  line.setAttribute("y2", String(y2));
  line.setAttribute("class", "tree-connection");
  treeConnections.append(line);
}

function summaryItem(label, value) {
  const item = document.createElement("span");
  item.className = "summary-item";
  const strong = document.createElement("strong");
  strong.textContent = String(value);
  item.append(document.createTextNode(`${label}: `), strong);
  return item;
}

function createNodeElement(node, answerIds) {
  const item = document.createElement("li");
  item.className = "tree-node";
  item.dataset.depth = String(node.depth);
  const card = document.createElement("article");
  card.className = `node-card status-${node.status}`;
  card.dataset.nodeId = node.id;

  const header = document.createElement("div");
  header.className = "node-card__header";
  const selectButton = document.createElement("button");
  selectButton.className = "node-select";
  selectButton.type = "button";
  selectButton.textContent = node.id;
  selectButton.setAttribute("aria-label", `Ver detalle del nodo ${node.id}`);
  selectButton.addEventListener("click", () => showNodeDetails(node));
  const depth = document.createElement("span");
  depth.className = "node-depth";
  depth.textContent = `Profundidad ${node.depth}`;
  header.append(selectButton, depth);
  card.append(header);

  const status = document.createElement("span");
  status.className = "status-label";
  status.textContent = statusLabels[node.status];
  card.append(status);

  if (answerIds.has(node.id)) {
    const answerMark = document.createElement("span");
    answerMark.className = "answer-mark";
    answerMark.textContent = "Solución";
    card.append(answerMark);
  }

  appendNodeField(card, "Meta evaluada", node.goal);
  if (node.clause !== null) appendNodeField(card, "Cláusula aplicada", node.clause);
  if (node.pending.length > 0) appendNodeList(card, "Metas pendientes", node.pending);
  if (node.bindings.length > 0) appendBindings(card, node.bindings);
  item.append(card);
  return item;
}

function appendNodeField(parent, label, value) {
  const field = document.createElement("div");
  field.className = "node-field";
  const fieldLabel = document.createElement("span");
  fieldLabel.className = "node-field__label";
  fieldLabel.textContent = label;
  const content = document.createElement("code");
  content.textContent = value;
  field.append(fieldLabel, content);
  parent.append(field);
}

function appendNodeList(parent, label, values) {
  const field = document.createElement("div");
  field.className = "node-field";
  const fieldLabel = document.createElement("span");
  fieldLabel.className = "node-field__label";
  fieldLabel.textContent = label;
  const list = document.createElement("ul");
  for (const value of values) {
    const item = document.createElement("li");
    item.textContent = value;
    list.append(item);
  }
  field.append(fieldLabel, list);
  parent.append(field);
}

function appendBindings(parent, bindings) {
  const field = document.createElement("div");
  field.className = "node-field";
  const fieldLabel = document.createElement("span");
  fieldLabel.className = "node-field__label";
  fieldLabel.textContent = "Sustituciones";
  field.append(fieldLabel);
  for (const binding of bindings) {
    const chip = document.createElement("span");
    chip.className = "binding-chip";
    chip.textContent = `${binding.var} = ${binding.value}`;
    field.append(chip);
  }
  parent.append(field);
}

function showNodeDetails(node) {
  for (const card of treeRoot.querySelectorAll(".node-card")) {
    const selected = card.dataset.nodeId === node.id;
    card.classList.toggle("is-selected", selected);
    card.querySelector(".node-select").setAttribute("aria-pressed", String(selected));
  }

  const heading = document.createElement("h2");
  heading.id = "details-title";
  heading.textContent = `Detalle del nodo ${node.id}`;
  const grid = document.createElement("dl");
  grid.className = "detail-grid";
  addDetail(grid, "Estado", statusLabels[node.status]);
  addDetail(grid, "Profundidad", node.depth);
  addDetail(grid, "Padre", node.parent === null ? "Raíz" : node.parent);
  addDetail(grid, "Meta evaluada", node.goal);
  addDetail(grid, "Cláusula aplicada", node.clause === null ? "Ninguna (nodo raíz)" : node.clause);
  addDetailList(grid, "Metas pendientes", node.pending);
  addDetailList(grid, "Sustituciones", node.bindings.map(binding => `${binding.var} = ${binding.value}`));
  addDetailList(grid, "Hijos", node.children.length > 0 ? node.children : ["Ninguno"]);
  nodeDetails.replaceChildren(heading, grid);
}

function addDetail(parent, label, value) {
  const item = document.createElement("div");
  item.className = "detail-item";
  const term = document.createElement("dt");
  term.textContent = label;
  const description = document.createElement("dd");
  description.textContent = String(value);
  item.append(term, description);
  parent.append(item);
}

function addDetailList(parent, label, values) {
  const item = document.createElement("div");
  item.className = "detail-item";
  const term = document.createElement("dt");
  term.textContent = label;
  const description = document.createElement("dd");
  if (values.length === 0) {
    description.textContent = "Ninguna";
  } else {
    const list = document.createElement("ul");
    for (const value of values) {
      const entry = document.createElement("li");
      entry.textContent = value;
      list.append(entry);
    }
    description.append(list);
  }
  item.append(term, description);
  parent.append(item);
}
