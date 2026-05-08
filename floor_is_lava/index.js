const fs = require("fs").promises;
const readline = require("readline");

// --- CONFIGURACIÓN DEL TABLERO ---
const FILAS = 6;
const COLUMNAS = 8;
const TOTAL_LAVA = 16;
const MAX_PASSES = 32;
const FILAS_LETRAS = ["A","B","C","D","E","F"];
const ARCHIVO_AUTOSAVE = "partida_autoguardada.json";

let matriz = [];
let posJugador = { fila: 0, col: 0 };
let puntosRestantes = MAX_PASSES;
let lavaVisible = false;

function crearTablero() {
    matriz = Array.from({ length: FILAS }, () => Array(COLUMNAS).fill("·"));
    matriz[0][0] = "T";   // Jugador
    matriz[5][7] = "*";   // Destino

    let lavaColocada = 0;
    while (lavaColocada < TOTAL_LAVA) {
        const fila = Math.floor(Math.random() * FILAS);
        const col = Math.floor(Math.random() * COLUMNAS);
        if (matriz[fila][col] === "·") {
            matriz[fila][col] = "L";
            lavaColocada++;
        }
    }
}

function mostrarTablero() {
    let header = " " + Array.from({length: COLUMNAS}, (_, i) => i).join("");
    console.log(header);
    for (let i = 0; i < FILAS; i++) {
        let filaStr = FILAS_LETRAS[i];
        for (let j = 0; j < COLUMNAS; j++) {
            const celda = matriz[i][j];
            if (celda === "L" && !lavaVisible && !(i===posJugador.fila && j===posJugador.col)) {
                filaStr += "·";
            } else {
                filaStr += celda;
            }
        }
        console.log(filaStr);
    }
    console.log(`Punts restants: ${puntosRestantes}`);
}


function distancia(destino) {
    return Math.abs(posJugador.fila - destino.fila) + Math.abs(posJugador.col - destino.col);
}

// --- Guardado / Carga ---
async function guardarPartida(filename) {
    try {
        const estado = { matriz, posJugador, puntosRestantes, lavaVisible };
        await fs.writeFile(filename, JSON.stringify(estado, null, 2));
        console.log(`Partida guardada automáticamente en ${filename}`);
    } catch (e) {
        console.error("Error guardando partida:", e);
    }
}

async function cargarPartida(filename) {
    try {
        const data = await fs.readFile(filename);
        const estado = JSON.parse(data);
        matriz = estado.matriz;
        posJugador = estado.posJugador;
        puntosRestantes = estado.puntosRestantes;
        lavaVisible = estado.lavaVisible;
        console.log(`Partida cargada desde ${filename}`);
    } catch (e) {
        console.log("No se encontró partida guardada, creando tablero nuevo...");
        crearTablero();
    }
}

// --- Activar / desactivar trampa ---
function toggleTrampa() {
    lavaVisible = !lavaVisible;
    console.log(`Trampa ${lavaVisible ? "activada" : "desactivada"}`);
    mostrarTablero();
}

// --- Movimiento ---
async function caminar(direccion) {
    let { fila, col } = posJugador;

    switch(direccion.toLowerCase()) {
        case "amunt": fila--; break;
        case "avall": fila++; break;
        case "dreta": col++; break;
        case "esquerra": col--; break;
        default:
            console.log("Direcció desconeguda. Usa amunt/avall/dreta/esquerra");
            return;
    }

    // Fuera del tablero
    if (fila < 0 || fila >= FILAS || col < 0 || col >= COLUMNAS) {
        console.log("Has perdut, has caigut per un penyasegat!");
        process.exit(0);
    }

    const casilla = matriz[fila][col];
    let mensaje = "";

    if (casilla === "L") {
        puntosRestantes--;
        mensaje = `Has trepitjat lava, perds un punt! Distància a destí: ${distancia({fila:5,col:7})}`;
    } else if (casilla === "*") {
        console.log("Has guanyat, has trobat el tresor!");
        process.exit(0);
    } else {
        mensaje = `Vas per bon camí, tens lava a ${distancia({fila:5,col:7})} caselles de distància`;
    }

    // Mover jugador
    matriz[posJugador.fila][posJugador.col] = "·";
    matriz[fila][col] = "T";
    posJugador = { fila, col };

    console.log(mensaje);
    mostrarTablero();

    // Guardado automático
    await guardarPartida(ARCHIVO_AUTOSAVE);

    if (puntosRestantes <= 0) {
        console.log("Has perdut, ja no tens més passes!");
        process.exit(0);
    }
}

// ---  Procesar comandos ---
const rl = readline.createInterface({ input: process.stdin, output: process.stdout, prompt: "Escriu una comanda: " });

async function procesarComando(input) {
    const [comando, arg] = input.trim().split(" ");

    switch(comando.toLowerCase()) {
        case "ajuda":
        case "help":
            console.log(`Comandes:
- ajuda / help
- caminar <amunt/avall/dreta/esquerra>
- puntuació
- activar/desactivar trampa
- guardar <archivo.json>
- carregar <archivo.json>`);
            break;

        case "caminar":
            if (!arg) console.log("Indica direcció: amunt, avall, dreta, esquerra");
            else await caminar(arg);
            break;

        case "puntuació":
            console.log(`Punts restants: ${puntosRestantes}, distància a destí: ${distancia({fila:5,col:7})}`);
            break;

        case "activar/desactivar":
            toggleTrampa();
            break;

        case "guardar":
            if (!arg) console.log("Indica archivo: guardar partida.json");
            else await guardarPartida(arg);
            break;

        case "carregar":
            if (!arg) console.log("Indica archivo: carregar partida.json");
            else await cargarPartida(arg);
            mostrarTablero();
            break;

        default:
            console.log("Comanda desconeguda. Escriu 'ajuda'");
    }
}

// --- Inicializar juego ---
(async function iniciarJuego() {
    await cargarPartida(ARCHIVO_AUTOSAVE);
    mostrarTablero();
    rl.prompt();
})();

rl.on("line", async (line) => {
    await procesarComando(line);
    rl.prompt();
}).on("close", () => {
    console.log("Adéu!");
    process.exit(0);
});