// Defineix les eines/funcions que hi ha disponibles a flutter
const tools = [
  {
    "type": "function",
    "function": {
      "name": "draw_circle",
      "description": "Dibuja un círculo con contorno y relleno opcional.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "string", "description": "ID numérico simple (ej: '1')"}, // <-- AÑADIDO
          "x": {"type": "number", "description": "Centro X"},
          "y": {"type": "number", "description": "Centro Y"},
          "radius": {"type": "number", "description": "Radio del círculo"},
          "strokeColor": {"type": "string", "description": "Color del borde HEX (ej: #FF0000)"},
          "fillColor": {"type": "string", "description": "Color de relleno HEX (ej: #00FF00)"},
          "strokeWidth": {"type": "number", "description": "Grosor del contorno"}
        },
        "required": ["x", "y", "radius", "id"] // <-- AÑADIDO ID COMO REQUERIDO
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_line",
      "description": "Dibuja una línea recta entre dos puntos.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "string", "description": "ID numérico simple (ej: '1')"}, // <-- AÑADIDO
          "startX": {"type": "number", "description": "X inicial"},
          "startY": {"type": "number", "description": "Y inicial"},
          "endX": {"type": "number", "description": "X final"},
          "endY": {"type": "number", "description": "Y final"},
          "color": {"type": "string", "description": "Color HEX"},
          "strokeWidth": {"type": "number", "description": "Grosor de la línea"}
        },
        "required": ["startX", "startY", "endX", "endY", "id"] // <-- AÑADIDO ID COMO REQUERIDO
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_rectangle",
      "description": "Dibuja un rectángulo con contorno y relleno.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "string", "description": "ID numérico simple (ej: '1')"}, // <-- AÑADIDO
          "topLeftX": {"type": "number", "description": "X superior izquierda"},
          "topLeftY": {"type": "number", "description": "Y superior izquierda"},
          "bottomRightX": {"type": "number", "description": "X inferior derecha"},
          "bottomRightY": {"type": "number", "description": "Y inferior derecha"},
          "strokeColor": {"type": "string", "description": "Color borde HEX"},
          "fillColor": {"type": "string", "description": "Color relleno HEX"},
          "strokeWidth": {"type": "number", "description": "Grosor borde"}
        },
        "required": ["topLeftX", "topLeftY", "bottomRightX", "bottomRightY", "id"] // <-- AÑADIDO ID COMO REQUERIDO
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "draw_text",
      "description": "Escribe un texto en el lienzo.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "string", "description": "ID numérico simple (ej: '1')"}, // <-- AÑADIDO
          "text": {"type": "string", "description": "El mensaje a escribir"},
          "x": {"type": "number", "description": "Posición X"},
          "y": {"type": "number", "description": "Posición Y"},
          "fontSize": {"type": "number", "description": "Tamaño de letra (ej: 20)"},
          "color": {"type": "string", "description": "Color HEX"},
          "isBold": {"type": "boolean", "description": "Si es negrita o no"}
        },
        "required": ["text", "x", "y", "id"] // <-- AÑADIDO ID COMO REQUERIDO
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "update_drawable",
      "description": "Modifica el color o posición de una figura existente usando su ID.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "string", "description": "El ID exacto que asignaste al crear la figura (ej: '1')"},
          "newColor": {"type": "string", "description": "Nuevo color HEX"},
          "newX": {"type": "number", "description": "Nueva posición X (o startX)"},
          "newY": {"type": "number", "description": "Nueva posición Y (o startY)"}
        },
        "required": ["id"]
      }
    }
  },
  {
    "type": "function",
    "function": {
      "name": "delete_drawable",
      "description": "Elimina una figura del lienzo usando su ID.",
      "parameters": {
        "type": "object",
        "properties": {
          "id": {"type": "string", "description": "El ID de la figura a borrar"}
        },
        "required": ["id"]
      }
    }
  }
];