"use strict";

const $ = id => document.querySelector(`#${id}`);

const dom = Object.freeze({
  fileInput: $("json-file"), loadMessage: $("load-message"),
  treeSection: $("tree-section"), treeTitle: $("tree-title"),
  treeSummary: $("tree-summary"), treeRoot: $("tree-root"),
  treeCanvas: $("tree-canvas"), treeConnections: $("tree-connections"),
  nodeDetails: $("node-details")
});

const medidas = Object.freeze({ anchoNodo: 290, espacioHorizontal: 32, espacioVertical: 48 });

const etiquetasEstado = Object.freeze({
  success: "Éxito", failure: "Fallo", cutoff: "Límite alcanzado"
});

const pipe = (...fns) => entrada => fns.reduce((valor, fn) => fn(valor), entrada);
const range = n => Array.from({ length: n }, (_, i) => i);
const maximo = valores => valores.reduce((max, v) => Math.max(max, v), -Infinity);

const esTexto = valor => typeof valor === "string";
const esEnteroNoNegativo = valor => Number.isInteger(valor) && valor >= 0;
const nuloO = pred => valor => valor === null || pred(valor);
const listaDe = pred => valor => Array.isArray(valor) && valor.every(pred);
const esBinding = b => Boolean(b) && esTexto(b.var) && esTexto(b.value);
const textoBinding = b => `${b.var} = ${b.value}`;

const Ok = value => Object.freeze({ isOk: true, value });
const Err = error => Object.freeze({ isOk: false, error });
const chain = fn => resultado => (resultado.isOk ? fn(resultado.value) : resultado);
const verificar = (pred, mensaje) => valor => (pred(valor) ? Ok(valor) : Err(mensaje));
const primerError = (mensajes, valor) => (mensajes.length > 0 ? Err(mensajes[0]) : Ok(valor));

const camposNodo = Object.freeze({
  id: v => esTexto(v) && v.length > 0,
  parent: nuloO(esTexto),
  depth: esEnteroNoNegativo,
  goal: esTexto,
  clause: nuloO(esTexto),
  pending: listaDe(esTexto),
  bindings: listaDe(esBinding),
  status: v => Object.prototype.hasOwnProperty.call(etiquetasEstado, v),
  children: listaDe(esTexto)
});

const esNodoValido = nodo =>
  Boolean(nodo) && Object.entries(camposNodo).every(([campo, pred]) => pred(nodo[campo]));

const esEncabezadoValido = d =>
  esTexto(d.query) && esEnteroNoNegativo(d.maxDepth) &&
  Array.isArray(d.nodes) && d.nodes.length > 0 && Array.isArray(d.answers);

const erroresDeNodo = ids => (nodo, i) =>
  !esNodoValido(nodo) ? ["Uno o más nodos tienen campos inválidos."]
    : ids.indexOf(nodo.id) !== i ? [`El identificador de nodo ${nodo.id} está repetido.`]
      : [];

const erroresDeEnlace = porId => nodo => {
  const padre = porId.get(nodo.parent);
  return [
    ...(nodo.parent !== null && !(padre && padre.children.includes(nodo.id))
      ? [`La relación padre-hijo de ${nodo.id} no es válida.`] : []),
    ...nodo.children
      .filter(id => !porId.has(id) || porId.get(id).parent !== nodo.id)
      .map(id => `La conexión de ${nodo.id} hacia ${id} no es válida.`)
  ];
};

const esRespuestaValida = porId => r => {
  const nodo = r && porId.get(r.node);
  return Boolean(nodo) && nodo.status === "success" && listaDe(esBinding)(r.bindings);
};

const visitar = porId => (id, vistos) =>
  vistos.includes(id)
    ? Err("El árbol contiene una conexión circular.")
    : porId.get(id).children.reduce(
        (res, hijo) => chain(v => visitar(porId)(hijo, v))(res), Ok([...vistos, id]));

const verificarAlcanzables = a =>
  chain(vistos => (vistos.length === a.data.nodes.length
    ? Ok(a)
    : Err("Hay nodos que no pertenecen a la raíz del árbol.")))(visitar(a.nodosPorId)(a.raiz.id, []));

const validarArbol = data =>
  pipe(
    chain(verificar(d => Boolean(d) && typeof d === "object" && !Array.isArray(d),
      "El archivo debe contener un objeto JSON.")),
    chain(verificar(esEncabezadoValido, "El JSON no cumple el formato de árbol SLD esperado.")),
    chain(d => primerError(d.nodes.flatMap(erroresDeNodo(d.nodes.map(n => n && n.id))), d)),
    chain(d => {
      const raices = d.nodes.filter(n => n.parent === null);
      return raices.length === 1 && raices[0] === d.nodes[0]
        ? Ok({ data: d, nodosPorId: new Map(d.nodes.map(n => [n.id, n])), raiz: raices[0] })
        : Err("El árbol debe tener una única raíz, ubicada al inicio de nodes.");
    }),
    chain(a => primerError(a.data.nodes.flatMap(erroresDeEnlace(a.nodosPorId)), a)),
    chain(verificar(a => a.data.answers.every(esRespuestaValida(a.nodosPorId)),
      "Una respuesta apunta a un nodo inexistente o no exitoso.")),
    chain(verificarAlcanzables)
  )(Ok(data));

const ubicarNodo = porId => (nodo, hoja) => {
  if (nodo.children.length === 0) {
    const centro = medidas.anchoNodo / 2 + hoja * (medidas.anchoNodo + medidas.espacioHorizontal);
    return { centro, hoja: hoja + 1, pares: [[nodo.id, centro]] };
  }
  const hijos = nodo.children.reduce((acc, id) => {
    const h = ubicarNodo(porId)(porId.get(id), acc.hoja);
    return { hoja: h.hoja, centros: [...acc.centros, h.centro], pares: [...acc.pares, ...h.pares] };
  }, { hoja, centros: [], pares: [] });
  const centro = (hijos.centros[0] + hijos.centros[hijos.centros.length - 1]) / 2;
  return { centro, hoja: hijos.hoja, pares: [...hijos.pares, [nodo.id, centro]] };
};

const calcularPosiciones = (raiz, porId) => {
  const { hoja, pares } = ubicarNodo(porId)(raiz, 0);
  const { anchoNodo, espacioHorizontal } = medidas;
  const ancho = Math.max(anchoNodo, hoja * anchoNodo + (hoja - 1) * espacioHorizontal);
  return { centros: new Map(pares), ancho };
};

const topesPorNivel = alturas =>
  alturas.slice(1).reduce((t, _, i) => [...t, t[i] + alturas[i] + medidas.espacioVertical], [0]);

const segmentosDeConexion = (x, y1, y2, xs) => {
  const yRama = y1 + (y2 - y1) / 2;
  return [
    [x, y1, x, yRama],
    ...(xs.length > 1 ? [[Math.min(...xs), yRama, Math.max(...xs), yRama]] : []),
    ...xs.map(c => [c, yRama, c, y2])
  ];
};

const el = (tag, { className, text, attrs = {}, dataset = {}, on = {} } = {}, hijos = []) => {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = String(text);
  Object.entries(dataset).forEach(([k, v]) => { e.dataset[k] = v; });
  Object.entries(attrs).forEach(([k, v]) => e.setAttribute(k, v));
  Object.entries(on).forEach(([k, v]) => e.addEventListener(k, v));
  e.append(...hijos);
  return e;
};

const lineaSvg = coords => {
  const linea = document.createElementNS("http://www.w3.org/2000/svg", "line");
  ["x1", "y1", "x2", "y2"].forEach((k, i) => linea.setAttribute(k, String(coords[i])));
  linea.setAttribute("class", "tree-connection");
  return linea;
};

const si = (condicion, construir) => (condicion ? [construir()] : []);
const lista = valores => el("ul", {}, valores.map(v => el("li", { text: v })));
const etiqueta = texto => el("span", { className: "node-field__label", text: texto });
const campo = (titulo, ...hijos) => el("div", { className: "node-field" }, [etiqueta(titulo), ...hijos]);

const tarjetaNodo = (nodo, esSolucion, alSeleccionar) =>
  el("article", { className: `node-card status-${nodo.status}`, dataset: { nodeId: nodo.id } }, [
    el("div", { className: "node-card__header" }, [
      el("button", { className: "node-select", text: nodo.id, on: { click: () => alSeleccionar(nodo) },
        attrs: { type: "button", "aria-label": `Ver detalle del nodo ${nodo.id}` } }),
      el("span", { className: "node-depth", text: `Profundidad ${nodo.depth}` })
    ]),
    el("span", { className: "status-label", text: etiquetasEstado[nodo.status] }),
    ...si(esSolucion, () => el("span", { className: "answer-mark", text: "Solución" })),
    campo("Meta evaluada", el("code", { text: nodo.goal })),
    ...si(nodo.clause !== null, () => campo("Cláusula aplicada", el("code", { text: nodo.clause }))),
    ...si(nodo.pending.length > 0, () => campo("Metas pendientes", lista(nodo.pending))),
    ...si(nodo.bindings.length > 0, () => campo("Sustituciones",
      ...nodo.bindings.map(b => el("span", { className: "binding-chip", text: textoBinding(b) }))))
  ]);

const detalle = ([titulo, valor]) =>
  el("div", { className: "detail-item" }, [
    el("dt", { text: titulo }),
    !Array.isArray(valor) ? el("dd", { text: valor })
      : valor.length === 0 ? el("dd", { text: "Ninguna" })
        : el("dd", {}, [lista(valor)])
  ]);

const contenidoDetalle = nodo => [
  el("h2", { text: `Detalle del nodo ${nodo.id}`, attrs: { id: "details-title" } }),
  el("dl", { className: "detail-grid" }, [
    ["Estado", etiquetasEstado[nodo.status]],
    ["Profundidad", nodo.depth],
    ["Padre", nodo.parent === null ? "Raíz" : nodo.parent],
    ["Meta evaluada", nodo.goal],
    ["Cláusula aplicada", nodo.clause === null ? "Ninguna (nodo raíz)" : nodo.clause],
    ["Metas pendientes", nodo.pending],
    ["Sustituciones", nodo.bindings.map(textoBinding)],
    ["Hijos", nodo.children.length > 0 ? nodo.children : ["Ninguno"]]
  ].map(detalle))
];

const mostrarMensaje = (mensaje, esError = false) => {
  dom.loadMessage.textContent = mensaje;
  dom.loadMessage.dataset.kind = esError ? "error" : "info";
};

const mostrarDetalle = nodo => {
  dom.treeRoot.querySelectorAll(".node-card").forEach(tarjeta => {
    const elegida = tarjeta.dataset.nodeId === nodo.id;
    tarjeta.classList.toggle("is-selected", elegida);
    tarjeta.querySelector(".node-select").setAttribute("aria-pressed", String(elegida));
  });
  dom.nodeDetails.replaceChildren(...contenidoDetalle(nodo));
};

const anchoVisible = () => {
  const margen = window.matchMedia("(max-width: 720px)").matches ? 16 : 48;
  return Math.max(medidas.anchoNodo, dom.treeCanvas.parentElement.clientWidth - margen);
};

const altoTarjeta = item => item.querySelector(".node-card").getBoundingClientRect().height;

const dibujarArbol = ({ data, nodosPorId, raiz }) => {
  dom.treeSection.hidden = false;
  const soluciones = new Set(data.answers.map(r => r.node));
  const pos = calcularPosiciones(raiz, nodosPorId);
  const ancho = Math.max(pos.ancho, anchoVisible());
  const centroDe = id => (ancho - pos.ancho) / 2 + pos.centros.get(id);

  dom.treeTitle.textContent = data.query;
  dom.treeSummary.replaceChildren(...[
    ["Profundidad máxima", data.maxDepth],
    ["Nodos", data.nodes.length],
    ["Soluciones", data.answers.length]
  ].map(([titulo, valor]) => el("span", { className: "summary-item" },
    [document.createTextNode(`${titulo}: `), el("strong", { text: valor })])));
  dom.treeCanvas.style.width = `${ancho}px`;
  dom.treeCanvas.style.height = "1px";
  dom.treeConnections.replaceChildren();

  const items = new Map(data.nodes.map(nodo => {
    const item = el("li", { className: "tree-node", dataset: { depth: String(nodo.depth) } },
      [tarjetaNodo(nodo, soluciones.has(nodo.id), mostrarDetalle)]);
    item.style.left = `${centroDe(nodo.id) - medidas.anchoNodo / 2}px`;
    item.style.top = "0";
    return [nodo.id, item];
  }));
  dom.treeRoot.replaceChildren(...items.values());

  const nivelMax = maximo(data.nodes.map(n => n.depth));
  const alturas = range(nivelMax + 1).map(nivel =>
    maximo(data.nodes.filter(n => n.depth === nivel).map(n => altoTarjeta(items.get(n.id)))));
  const topes = topesPorNivel(alturas);
  const alto = topes[nivelMax] + alturas[nivelMax];

  data.nodes.forEach(n => { items.get(n.id).style.top = `${topes[n.depth]}px`; });
  dom.treeCanvas.style.height = `${alto}px`;
  [["width", ancho], ["height", alto], ["viewBox", `0 0 ${ancho} ${alto}`]]
    .forEach(([k, v]) => dom.treeConnections.setAttribute(k, String(v)));

  dom.treeConnections.replaceChildren(...data.nodes
    .filter(n => n.children.length > 0)
    .flatMap(n => segmentosDeConexion(centroDe(n.id), topes[n.depth] + altoTarjeta(items.get(n.id)),
      topes[n.depth + 1], n.children.map(centroDe)))
    .map(lineaSvg));

  mostrarDetalle(raiz);
};

const extraer = resultado => {
  if (!resultado.isOk) throw new Error(resultado.error);
  return resultado.value;
};

const cargarArchivo = archivo =>
  archivo.text()
    .then(JSON.parse)
    .then(validarArbol)
    .then(extraer)
    .then(dibujarArbol)
    .then(() => mostrarMensaje(`Archivo cargado: ${archivo.name}`))
    .catch(error => mostrarMensaje(error instanceof SyntaxError
      ? "No se pudo leer el archivo: el contenido no es JSON válido." : error.message, true))
    .finally(() => { dom.fileInput.value = ""; });

dom.fileInput.addEventListener("change", () => {
  const archivo = dom.fileInput.files && dom.fileInput.files[0];
  if (archivo) cargarArchivo(archivo);
});