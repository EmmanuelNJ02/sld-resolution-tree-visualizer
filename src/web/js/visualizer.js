"use strict";

const dom = Object.freeze({
  fileInput: document.querySelector("#json-file"),
  loadMessage: document.querySelector("#load-message"),
  treeSection: document.querySelector("#tree-section"),
  treeTitle: document.querySelector("#tree-title"),
  treeSummary: document.querySelector("#tree-summary"),
  treeRoot: document.querySelector("#tree-root"),
  treeCanvas: document.querySelector("#tree-canvas"),
  treeConnections: document.querySelector("#tree-connections"),
  nodeDetails: document.querySelector("#node-details")
});

const medidas = Object.freeze({
  anchoNodo: 290,
  espacioHorizontal: 32,
  espacioVertical: 48
});

const svgNamespace = "http://www.w3.org/2000/svg";

const etiquetasEstado = Object.freeze({
  success: "Éxito",
  failure: "Fallo",
  cutoff: "Límite alcanzado"
});

const pipe = (...fns) => entrada => fns.reduce((valor, fn) => fn(valor), entrada);

const range = n => Array.from({ length: n }, (_, i) => i);

const maximo = valores => valores.reduce((max, v) => Math.max(max, v), -Infinity);

const esTexto = valor => typeof valor === "string";
const esEnteroNoNegativo = valor => Number.isInteger(valor) && valor >= 0;

const nuloO = pred => valor => valor === null || pred(valor);
const listaDe = pred => valor => Array.isArray(valor) && valor.every(pred);

const esBinding = binding =>
  Boolean(binding) && esTexto(binding.var) && esTexto(binding.value);

const esEstado = estado => Object.prototype.hasOwnProperty.call(etiquetasEstado, estado);

const textoBinding = binding => `${binding.var} = ${binding.value}`;

const Ok = value => Object.freeze({ isOk: true, value });
const Err = error => Object.freeze({ isOk: false, error });

const chain = fn => resultado => (resultado.isOk ? fn(resultado.value) : resultado);

const verificar = (pred, mensaje) => valor =>
  (pred(valor) ? Ok(valor) : Err(mensaje));

const primerError = (mensajes, valor) =>
  (mensajes.length > 0 ? Err(mensajes[0]) : Ok(valor));

const esObjeto = data =>
  Boolean(data) && typeof data === "object" && !Array.isArray(data);

const tieneEncabezado = data =>
  esTexto(data.query) &&
  esEnteroNoNegativo(data.maxDepth) &&
  Array.isArray(data.nodes) && data.nodes.length > 0 &&
  Array.isArray(data.answers);

const esNodoValido = nodo =>
  Boolean(nodo) &&
  esTexto(nodo.id) && nodo.id.length > 0 &&
  nuloO(esTexto)(nodo.parent) &&
  esEnteroNoNegativo(nodo.depth) &&
  esTexto(nodo.goal) &&
  nuloO(esTexto)(nodo.clause) &&
  listaDe(esTexto)(nodo.pending) &&
  listaDe(esBinding)(nodo.bindings) &&
  esEstado(nodo.status) &&
  listaDe(esTexto)(nodo.children);

const erroresDeNodo = ids => (nodo, i) =>
  !esNodoValido(nodo)
    ? ["Uno o más nodos tienen campos inválidos."]
    : ids.indexOf(nodo.id) !== i
      ? [`El identificador de nodo ${nodo.id} está repetido.`]
      : [];

const verificarNodos = data =>
  primerError(data.nodes.flatMap(erroresDeNodo(data.nodes.map(nodo => nodo && nodo.id))), data);

const indexarNodos = data =>
  Ok({ data, nodosPorId: new Map(data.nodes.map(nodo => [nodo.id, nodo])) });

const buscarRaiz = arbol => {
  const raices = arbol.data.nodes.filter(nodo => nodo.parent === null);
  return raices.length === 1 && raices[0] === arbol.data.nodes[0]
    ? Ok({ ...arbol, raiz: raices[0] })
    : Err("El árbol debe tener una única raíz, ubicada al inicio de nodes.");
};

const erroresDeEnlace = nodosPorId => nodo => {
  const padre = nodo.parent === null ? null : nodosPorId.get(nodo.parent);
  const errorPadre =
    nodo.parent !== null && (!padre || !padre.children.includes(nodo.id))
      ? [`La relación padre-hijo de ${nodo.id} no es válida.`]
      : [];
  const erroresHijos = nodo.children
    .filter(idHijo => {
      const hijo = nodosPorId.get(idHijo);
      return !hijo || hijo.parent !== nodo.id;
    })
    .map(idHijo => `La conexión de ${nodo.id} hacia ${idHijo} no es válida.`);
  return [...errorPadre, ...erroresHijos];
};

const verificarEnlaces = arbol =>
  primerError(arbol.data.nodes.flatMap(erroresDeEnlace(arbol.nodosPorId)), arbol);

const esRespuestaValida = nodosPorId => respuesta => {
  const nodo = respuesta && nodosPorId.get(respuesta.node);
  return Boolean(nodo) && nodo.status === "success" && listaDe(esBinding)(respuesta.bindings);
};

const verificarRespuestas = arbol =>
  verificar(
    a => a.data.answers.every(esRespuestaValida(a.nodosPorId)),
    "Una respuesta apunta a un nodo inexistente o no exitoso."
  )(arbol);

const visitar = nodosPorId => (id, visitados) =>
  visitados.includes(id)
    ? Err("El árbol contiene una conexión circular.")
    : nodosPorId.get(id).children.reduce(
        (resultado, idHijo) => chain(vistos => visitar(nodosPorId)(idHijo, vistos))(resultado),
        Ok([...visitados, id])
      );

const verificarAlcanzables = arbol =>
  chain(visitados => (visitados.length === arbol.data.nodes.length
    ? Ok(arbol)
    : Err("Hay nodos que no pertenecen a la raíz del árbol.")))(visitar(arbol.nodosPorId)(arbol.raiz.id, []));

const validarArbol = data =>
  pipe(
    chain(verificar(esObjeto, "El archivo debe contener un objeto JSON.")),
    chain(verificar(tieneEncabezado, "El JSON no cumple el formato de árbol SLD esperado.")),
    chain(verificarNodos),
    chain(indexarNodos),
    chain(buscarRaiz),
    chain(verificarEnlaces),
    chain(verificarRespuestas),
    chain(verificarAlcanzables)
  )(Ok(data));

const ubicarNodo = nodosPorId => (nodo, siguienteHoja) => {
  if (nodo.children.length === 0) {
    const centro = medidas.anchoNodo / 2 + siguienteHoja * (medidas.anchoNodo + medidas.espacioHorizontal);
    return { centro, siguienteHoja: siguienteHoja + 1, pares: [[nodo.id, centro]] };
  }

  const hijos = nodo.children.reduce(
    (acc, idHijo) => {
      const ubicado = ubicarNodo(nodosPorId)(nodosPorId.get(idHijo), acc.siguienteHoja);
      return {
        siguienteHoja: ubicado.siguienteHoja,
        centros: [...acc.centros, ubicado.centro],
        pares: [...acc.pares, ...ubicado.pares]
      };
    },
    { siguienteHoja, centros: [], pares: [] }
  );

  const centro = (hijos.centros[0] + hijos.centros[hijos.centros.length - 1]) / 2;
  return { centro, siguienteHoja: hijos.siguienteHoja, pares: [...hijos.pares, [nodo.id, centro]] };
};

const calcularPosiciones = (raiz, nodosPorId) => {
  const { siguienteHoja, pares } = ubicarNodo(nodosPorId)(raiz, 0);
  const ancho = Math.max(
    medidas.anchoNodo,
    siguienteHoja * medidas.anchoNodo + (siguienteHoja - 1) * medidas.espacioHorizontal
  );
  return { centros: new Map(pares), ancho };
};

const alturasPorNivel = (mediciones, nivelMaximo) =>
  range(nivelMaximo + 1).map(nivel =>
    maximo(mediciones.filter(m => m.nivel === nivel).map(m => m.alto)));

const topesPorNivel = alturas =>
  alturas.slice(1).reduce(
    (topes, _, i) => [...topes, topes[i] + alturas[i] + medidas.espacioVertical],
    [0]
  );

const segmentosDeConexion = ({ centroPadre, basePadre, topeHijos, centrosHijos }) => {
  const yRama = basePadre + (topeHijos - basePadre) / 2;
  const barra = centrosHijos.length > 1
    ? [[Math.min(...centrosHijos), yRama, Math.max(...centrosHijos), yRama]]
    : [];
  return [
    [centroPadre, basePadre, centroPadre, yRama],
    ...barra,
    ...centrosHijos.map(c => [c, yRama, c, topeHijos])
  ];
};

const el = (tag, { className, text, attrs = {}, dataset = {}, on = {} } = {}, hijos = []) => {
  const elemento = document.createElement(tag);
  if (className) elemento.className = className;
  if (text !== undefined) elemento.textContent = String(text);
  Object.entries(dataset).forEach(([clave, valor]) => { elemento.dataset[clave] = valor; });
  Object.entries(attrs).forEach(([clave, valor]) => elemento.setAttribute(clave, valor));
  Object.entries(on).forEach(([evento, manejador]) => elemento.addEventListener(evento, manejador));
  elemento.append(...hijos);
  return elemento;
};

const lineaSvg = ([x1, y1, x2, y2]) => {
  const linea = document.createElementNS(svgNamespace, "line");
  [["x1", x1], ["y1", y1], ["x2", x2], ["y2", y2], ["class", "tree-connection"]]
    .forEach(([nombre, valor]) => linea.setAttribute(nombre, String(valor)));
  return linea;
};

const itemResumen = (etiqueta, valor) =>
  el("span", { className: "summary-item" }, [
    document.createTextNode(`${etiqueta}: `),
    el("strong", { text: valor })
  ]);

const etiquetaCampo = etiqueta => el("span", { className: "node-field__label", text: etiqueta });

const campoNodo = (etiqueta, valor) =>
  el("div", { className: "node-field" }, [etiquetaCampo(etiqueta), el("code", { text: valor })]);

const listaNodo = (etiqueta, valores) =>
  el("div", { className: "node-field" }, [
    etiquetaCampo(etiqueta),
    el("ul", {}, valores.map(valor => el("li", { text: valor })))
  ]);

const campoBindings = bindings =>
  el("div", { className: "node-field" }, [
    etiquetaCampo("Sustituciones"),
    ...bindings.map(binding => el("span", { className: "binding-chip", text: textoBinding(binding) }))
  ]);

const si = (condicion, construir) => (condicion ? [construir()] : []);

const tarjetaNodo = (nodo, esSolucion, alSeleccionar) =>
  el("article", { className: `node-card status-${nodo.status}`, dataset: { nodeId: nodo.id } }, [
    el("div", { className: "node-card__header" }, [
      el("button", {
        className: "node-select",
        text: nodo.id,
        attrs: { type: "button", "aria-label": `Ver detalle del nodo ${nodo.id}` },
        on: { click: () => alSeleccionar(nodo) }
      }),
      el("span", { className: "node-depth", text: `Profundidad ${nodo.depth}` })
    ]),
    el("span", { className: "status-label", text: etiquetasEstado[nodo.status] }),
    ...si(esSolucion, () => el("span", { className: "answer-mark", text: "Solución" })),
    campoNodo("Meta evaluada", nodo.goal),
    ...si(nodo.clause !== null, () => campoNodo("Cláusula aplicada", nodo.clause)),
    ...si(nodo.pending.length > 0, () => listaNodo("Metas pendientes", nodo.pending)),
    ...si(nodo.bindings.length > 0, () => campoBindings(nodo.bindings))
  ]);

const itemNodo = (nodo, esSolucion, alSeleccionar) =>
  el("li", { className: "tree-node", dataset: { depth: String(nodo.depth) } },
    [tarjetaNodo(nodo, esSolucion, alSeleccionar)]);

const itemDetalle = (etiqueta, valor) =>
  el("div", { className: "detail-item" }, [el("dt", { text: etiqueta }), el("dd", { text: valor })]);

const listaDetalle = (etiqueta, valores) =>
  el("div", { className: "detail-item" }, [
    el("dt", { text: etiqueta }),
    valores.length === 0
      ? el("dd", { text: "Ninguna" })
      : el("dd", {}, [el("ul", {}, valores.map(valor => el("li", { text: valor })))])
  ]);

const contenidoDetalle = nodo => [
  el("h2", { text: `Detalle del nodo ${nodo.id}`, attrs: { id: "details-title" } }),
  el("dl", { className: "detail-grid" }, [
    itemDetalle("Estado", etiquetasEstado[nodo.status]),
    itemDetalle("Profundidad", nodo.depth),
    itemDetalle("Padre", nodo.parent === null ? "Raíz" : nodo.parent),
    itemDetalle("Meta evaluada", nodo.goal),
    itemDetalle("Cláusula aplicada", nodo.clause === null ? "Ninguna (nodo raíz)" : nodo.clause),
    listaDetalle("Metas pendientes", nodo.pending),
    listaDetalle("Sustituciones", nodo.bindings.map(textoBinding)),
    listaDetalle("Hijos", nodo.children.length > 0 ? nodo.children : ["Ninguno"])
  ])
];

const mostrarMensaje = (mensaje, esError = false) => {
  dom.loadMessage.textContent = mensaje;
  dom.loadMessage.dataset.kind = esError ? "error" : "info";
};

const mostrarDetalle = nodo => {
  dom.treeRoot.querySelectorAll(".node-card").forEach(tarjeta => {
    const seleccionada = tarjeta.dataset.nodeId === nodo.id;
    tarjeta.classList.toggle("is-selected", seleccionada);
    tarjeta.querySelector(".node-select").setAttribute("aria-pressed", String(seleccionada));
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

  const idsSolucion = new Set(data.answers.map(respuesta => respuesta.node));
  const posiciones = calcularPosiciones(raiz, nodosPorId);
  const ancho = Math.max(posiciones.ancho, anchoVisible());
  const desplazamiento = (ancho - posiciones.ancho) / 2;
  const centroDe = id => desplazamiento + posiciones.centros.get(id);

  dom.treeTitle.textContent = data.query;
  dom.treeSummary.replaceChildren(
    itemResumen("Profundidad máxima", data.maxDepth),
    itemResumen("Nodos", data.nodes.length),
    itemResumen("Soluciones", data.answers.length)
  );
  dom.treeCanvas.style.width = `${ancho}px`;
  dom.treeCanvas.style.height = "1px";
  dom.treeConnections.replaceChildren();

  const items = new Map(data.nodes.map(nodo => {
    const item = itemNodo(nodo, idsSolucion.has(nodo.id), mostrarDetalle);
    item.style.left = `${centroDe(nodo.id) - medidas.anchoNodo / 2}px`;
    item.style.top = "0";
    return [nodo.id, item];
  }));
  dom.treeRoot.replaceChildren(...items.values());

  const nivelMaximo = maximo(data.nodes.map(nodo => nodo.depth));
  const alturas = alturasPorNivel(
    data.nodes.map(nodo => ({ nivel: nodo.depth, alto: altoTarjeta(items.get(nodo.id)) })),
    nivelMaximo
  );
  const topes = topesPorNivel(alturas);
  const alto = topes[nivelMaximo] + alturas[nivelMaximo];

  data.nodes.forEach(nodo => { items.get(nodo.id).style.top = `${topes[nodo.depth]}px`; });
  dom.treeCanvas.style.height = `${alto}px`;
  dom.treeConnections.setAttribute("width", String(ancho));
  dom.treeConnections.setAttribute("height", String(alto));
  dom.treeConnections.setAttribute("viewBox", `0 0 ${ancho} ${alto}`);

  const segmentos = data.nodes
    .filter(nodo => nodo.children.length > 0)
    .flatMap(nodo => segmentosDeConexion({
      centroPadre: centroDe(nodo.id),
      basePadre: topes[nodo.depth] + altoTarjeta(items.get(nodo.id)),
      topeHijos: topes[nodo.depth + 1],
      centrosHijos: nodo.children.map(centroDe)
    }));
  dom.treeConnections.replaceChildren(...segmentos.map(lineaSvg));

  mostrarDetalle(raiz);
};

const mensajeDeError = error =>
  (error instanceof SyntaxError
    ? "No se pudo leer el archivo: el contenido no es JSON válido."
    : error.message);

const extraer = resultado => {
  if (!resultado.isOk) throw new Error(resultado.error);
  return resultado.value;
};

const cargarArchivo = archivo =>
  archivo.text()
    .then(texto => JSON.parse(texto))
    .then(validarArbol)
    .then(extraer)
    .then(dibujarArbol)
    .then(() => mostrarMensaje(`Archivo cargado: ${archivo.name}`))
    .catch(error => mostrarMensaje(mensajeDeError(error), true))
    .finally(() => { dom.fileInput.value = ""; });

dom.fileInput.addEventListener("change", () => {
  const archivo = dom.fileInput.files && dom.fileInput.files[0];
  if (archivo) cargarArchivo(archivo);
});