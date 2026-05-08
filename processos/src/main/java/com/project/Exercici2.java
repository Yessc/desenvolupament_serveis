package com.project;

import java.util.concurrent.CompletableFuture;

public class Exercici2 {
    public static void main(String[] args) {

        CompletableFuture<String> proces = CompletableFuture.supplyAsync(() -> {
            System.out.println("[ETAPA 1] Validant dades de la sol·licitud...");
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
            }
            return "Dades d'usuari vàlides";
        }).thenApply(resultatAnterior -> {
            System.out.println("[ETAPA 2] Processant dades: " + resultatAnterior);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
            }
            return "Resultat del càlcul: 200 OK";
        }).thenApply(res -> {
            // Pas intermedi opcional per formatar la resposta
            return res.toUpperCase();
        });

        proces.thenAccept(respostaFinal -> {
            System.out.println("[ETAPA 3] Resposta enviada a l'usuari: " + respostaFinal);
        });

        // Esperem que la cadena acabi abans de tancar el programa
        proces.join();

        System.out.println("--- Procés asíncron finalitzat ---");
    }
}