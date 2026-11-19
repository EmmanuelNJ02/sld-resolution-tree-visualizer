# Visualizador web de árboles SLD - Parte C

## Alcance

La interfaz de `src/web/` consume el JSON definido en [TREE_JSON_FORMAT.md](./TREE_JSON_FORMAT.md). Presenta el árbol completo, las metas, las cláusulas, las sustituciones y los estados de cada rama. No ejecuta consultas Prolog ni construye o modifica el árbol.

## Uso

Desde la raíz del repositorio, inicia un servidor HTTP local:

```powershell
python -m http.server 8000
```

Abre `http://localhost:8000/src/web/` en el navegador. Selecciona un ejemplo y pulsa **Cargar ejemplo**, o usa **Elegir archivo JSON** para cargar un archivo exportado. La carga desde archivo también funciona si se abre `src/web/index.html` directamente.

El selector de ejemplos usa `fetch`; por eso requiere el servidor HTTP. Si la página se abrió directamente como archivo, la interfaz explica ese límite y se puede seguir usando la carga manual.

## Funcionamiento

- `index.html` contiene los controles y las regiones de la interfaz.
- `js/visualizer.js` lee, valida y representa los datos recibidos. Rechaza estructuras incompletas, referencias inconsistentes, ciclos y respuestas que no apunten a nodos exitosos. Cada carga válida reemplaza el árbol visible; el mismo archivo se puede volver a seleccionar.
- `css/visualizer.css` presenta los nodos y estilos diferentes para `success`, `failure` y `cutoff`. Las conexiones SVG se calculan para centrar los nodos padre sobre sus hijos, incluso en ramas con distinto número de descendientes.
- Al seleccionar el identificador de un nodo se actualiza el panel con su profundidad, padre, metas, cláusula, sustituciones e hijos.

Los valores del JSON se insertan como texto, no como HTML. Los nodos de solución se identifican con las entradas de `answers`.

## Pruebas iniciales

Se incluyen seis ejemplos del repositorio: backtracking, soluciones múltiples, fallo, recursión, límite de profundidad y recursión con alternativas. Cada JSON sirve para comprobar visualmente estados y estructuras diferentes. La interfaz debe contrastarse con el JSON de origen; esta primera versión no incluye pruebas automatizadas de navegador.

## Limitaciones actuales

- El árbol se muestra completo y no ofrece plegado de ramas.
- El diseño permite desplazamiento horizontal para árboles anchos; en árboles muy grandes, la cantidad de nodos puede afectar la legibilidad.
- La interfaz depende del formato documentado por Parte B; cualquier cambio al contrato debe reflejarse también en el validador.
- La página no crea ni exporta archivos JSON.
