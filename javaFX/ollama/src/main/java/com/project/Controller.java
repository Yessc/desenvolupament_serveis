package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;
import javafx.application.Platform;
import javafx.stage.FileChooser;
import javafx.event.ActionEvent;

import java.io.File;
import java.io.InputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpRequest.BodyPublishers;
import java.util.Base64;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

import org.json.JSONArray;
import org.json.JSONObject;

public class Controller {

    // Modelos de Ollama
    private static final String TEXT_MODEL = "gemma3:1b";
    private static final String VISION_MODEL = "llava-phi3";

    @FXML private VBox chatBox;
    @FXML private TextField messageField;
    @FXML private Button sendButton, imageButton, cancelButton;
    @FXML private ImageView previewImage;

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private CompletableFuture<HttpResponse<InputStream>> streamRequest;
    private CompletableFuture<HttpResponse<String>> completeRequest;
    private InputStream currentInputStream;
    private Future<?> streamReadingTask;
    private final AtomicBoolean isCancelled = new AtomicBoolean(false);
    private final ExecutorService executorService = Executors.newSingleThreadExecutor();
    private volatile boolean isFirst = false;
    private String selectedImageBase64 = null;
    private File selectedImageFile = null;

    // ----------------- Acciones UI -----------------

    @FXML
    private void selectImage(ActionEvent event) {
        FileChooser fc = new FileChooser();
        fc.setTitle("Selecciona una imagen");
        fc.getExtensionFilters().add(new FileChooser.ExtensionFilter("Imágenes", "*.png", "*.jpg", "*.jpeg", "*.bmp", "*.gif"));

        File file = fc.showOpenDialog(imageButton.getScene().getWindow());
        if (file != null) {
        try {
             selectedImageFile = file;

            byte[] bytes = Files.readAllBytes(file.toPath());
            selectedImageBase64 = Base64.getEncoder().encodeToString(bytes);

            // mostrar preview
            Image img = new Image(file.toURI().toString());
            previewImage.setImage(img);

            appendMessage("Sistema: Imagen cargada, ahora escribe el mensaje.");

        } catch (Exception e) {
            appendMessage("Error al leer la imagen.");
        }
    }
    }

    // Enviar mensaje (texto o texto+imagen)
    @FXML
    private void sendMessage(ActionEvent event) {
        String userText = messageField.getText().trim();
        if (userText.isEmpty() && selectedImageBase64 == null) return;

        // Mostrar en chat
        appendMessage("Usuario: " + userText);
        // mostrar imagen en el chat
        if (selectedImageFile != null) {
            appendImage(selectedImageFile);
        }

        messageField.clear();

        isCancelled.set(false);
        setButtonsRunning();

        if (selectedImageBase64 != null) {

            executeImageRequest(VISION_MODEL, userText, selectedImageBase64);

            selectedImageBase64 = null;
            selectedImageFile = null;
            previewImage.setImage(null);

        } else {

            executeTextRequest(TEXT_MODEL, userText, true);
        }
    }

    // Cancelar request peticion
    @FXML
    private void cancelRequest(ActionEvent event) {
        isCancelled.set(true);
        cancelStreamRequest();
        cancelCompleteRequest();
        appendMessage("Sistema: Request cancelada.");
        setButtonsIdle();
    }
    // agregar imagen al scroll
    private void appendImage(File file) {

    Platform.runLater(() -> {

        Image image = new Image(file.toURI().toString());

        ImageView imageView = new ImageView(image);
        imageView.setFitWidth(250);   // tamaño máximo
        imageView.setPreserveRatio(true);

        chatBox.getChildren().add(imageView);

    });
}

    // ----------------- Helpers UI -----------------
    private void appendMessage(String message) {
        Platform.runLater(() -> chatBox.getChildren().add(new Text(message)));
    }

    private void setButtonsRunning() {
        sendButton.setDisable(true);
        imageButton.setDisable(true);
        cancelButton.setDisable(false);
        messageField.setDisable(false);
    }

    private void setButtonsIdle() {
        sendButton.setDisable(false);
        imageButton.setDisable(false);
        cancelButton.setDisable(true);
        messageField.setDisable(false);
        streamRequest = null;
        completeRequest = null;
    }

    // ----------------- Requests -----------------

    private void executeTextRequest(String model, String prompt, boolean stream) {
        JSONObject body = new JSONObject()
                .put("model", model)
                .put("prompt", prompt)
                .put("stream", stream)
                .put("keep_alive", "10m");

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:11434/api/generate"))
                .header("Content-Type", "application/json")
                .POST(BodyPublishers.ofString(body.toString()))
                .build();

        if (stream) {
            appendMessage("Ollama Thinking...");
            isFirst = true;

            streamRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofInputStream())
                    .thenApply(response -> {
                        currentInputStream = response.body();
                        streamReadingTask = executorService.submit(this::handleStreamResponse);
                        return response;
                    })
                    .exceptionally(e -> {
                        if (!isCancelled.get()) e.printStackTrace();
                        setButtonsIdle();
                        return null;
                    });

        } else {
            appendMessage("Ollama Thinking...");
            completeRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofString())
                    .thenApply(response -> {
                        String respText = safeExtractTextResponse(response.body());
                        appendMessage("Ollama: " + respText);
                        setButtonsIdle();
                        return response;
                    })
                    .exceptionally(e -> { e.printStackTrace(); setButtonsIdle(); return null; });
        }
    }

    private void executeImageRequest(String model, String prompt, String base64Image) {
        appendMessage("Sistema: Analyzing picture...");

        JSONObject body = new JSONObject()
                .put("model", model)
                .put("prompt", prompt)
                .put("images", new JSONArray().put(base64Image))
                .put("stream", false)
                .put("keep_alive", "10m")
                .put("options", new JSONObject()
                        .put("num_ctx", 2048)
                        .put("num_predict", 256)
                );

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:11434/api/generate"))
                .header("Content-Type", "application/json")
                .POST(BodyPublishers.ofString(body.toString()))
                .build();

        completeRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofString())
                .thenApply(resp -> {
                    String msg = tryParseAnyMessage(resp.body());
                    if (msg == null || msg.isBlank()) msg = "(empty response)";
                    appendMessage("Ollama: " + msg);
                    setButtonsIdle();
                    return resp;
                })
                .exceptionally(e -> { e.printStackTrace(); appendMessage("Error durante la petición."); setButtonsIdle(); return null; });
    }

    // ----------------- Stream -----------------

    private void handleStreamResponse() {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(currentInputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (isCancelled.get()) break;
                if (line.isBlank()) continue;

                JSONObject jsonResponse = new JSONObject(line);
                // respuesta del ia
                String chunk = jsonResponse.optString("response", "");
                if (chunk.isEmpty()) continue;

                if (isFirst) {
                    appendMessage("Ollama: " + chunk);
                    isFirst = false;
                } else {
                    Platform.runLater(() -> {
                        int lastIndex = chatBox.getChildren().size() - 1;
                        Text last = (Text) chatBox.getChildren().get(lastIndex);
                        last.setText(last.getText() + chunk);
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            appendMessage("Error durante streaming.");
        } finally {
            try { if (currentInputStream != null) currentInputStream.close(); } catch (Exception ignored) {}
            setButtonsIdle();
        }
    }

    // ----------------- Utils -----------------

    private void cancelStreamRequest() {
        if (streamRequest != null && !streamRequest.isDone()) {
            try { if (currentInputStream != null) currentInputStream.close(); } catch (Exception ignored) {}
            if (streamReadingTask != null) streamReadingTask.cancel(true);
            streamRequest.cancel(true);
        }
    }

    private void cancelCompleteRequest() {
        if (completeRequest != null && !completeRequest.isDone()) completeRequest.cancel(true);
    }

    private String safeExtractTextResponse(String bodyStr) {
        try {
            JSONObject o = new JSONObject(bodyStr);
            String r = o.optString("response", null);
            if (r != null && !r.isBlank()) return r;
            if (o.has("message")) return o.optString("message");
            if (o.has("error")) return "Error: " + o.optString("error");
        } catch (Exception ignored) {}
        return bodyStr != null && !bodyStr.isBlank() ? bodyStr : "(empty)";
    }

    private String tryParseAnyMessage(String bodyStr) {
        try {
            JSONObject o = new JSONObject(bodyStr);
            if (o.has("response")) return o.optString("response", "");
            if (o.has("message")) return o.optString("message", "");
            if (o.has("error")) return "Error: " + o.optString("error");
        } catch (Exception ignored) {}
        return null;
    }
}