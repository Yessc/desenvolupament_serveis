package com.project;

import java.util.Arrays;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicReference;

public class Main {

    // Conjunt gran de dades (simulat)
    private static final double[] dades = new double[1000];

    // (thread-safe)
    private static final AtomicReference<Double> suma = new AtomicReference<>(0.0);
    private static final AtomicReference<Double> mitjana = new AtomicReference<>(0.0);
    private static final AtomicReference<Double> desviacio = new AtomicReference<>(0.0);

    public static void main(String[] args) {

        // Inicialitzem dades amb valors aleatoris
        for (int i = 0; i < dades.length; i++) {
            dades[i] = ThreadLocalRandom.current().nextDouble(1, 100);
        }

        // Barrera amb 3 participants
        CyclicBarrier barrera = new CyclicBarrier(3, () -> {
            System.out.println("\n=== Tots els càlculs han finalitzat ===");
            mostrarResultats();
        });

        ExecutorService executor = Executors.newFixedThreadPool(3);

        executor.submit(calculSuma(barrera));
        executor.submit(calculMitjana(barrera));
        executor.submit(calculDesviacio(barrera));

        executor.shutdown();
        try {
            executor.awaitTermination(10, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            executor.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }

    private static Runnable calculSuma(CyclicBarrier barrera) {
        return () -> {
            try {
                System.out.println("Calculant suma...");
                double total = Arrays.stream(dades).sum();
                Thread.sleep(500); // simulació temps procés
                suma.set(total);
                barrera.await();
            } catch (Exception e) {
                Thread.currentThread().interrupt();
            }
        };
    }

    private static Runnable calculMitjana(CyclicBarrier barrera) {
        return () -> {
            try {
                System.out.println("Calculant mitjana...");
                double avg = Arrays.stream(dades).average().orElse(0.0);
                Thread.sleep(700);
                mitjana.set(avg);
                barrera.await();
            } catch (Exception e) {
                Thread.currentThread().interrupt();
            }
        };
    }

    private static Runnable calculDesviacio(CyclicBarrier barrera) {
        return () -> {
            try {
                System.out.println("Calculant desviació estàndard...");
                double avg = Arrays.stream(dades).average().orElse(0.0);
                double variance = Arrays.stream(dades)
                        .map(d -> Math.pow(d - avg, 2))
                        .sum() / dades.length;

                double std = Math.sqrt(variance);
                Thread.sleep(900);
                desviacio.set(std);
                barrera.await();
            } catch (Exception e) {
                Thread.currentThread().interrupt();
            }
        };
    }

    // 🔹 Mostra resultats finals (executat per la CyclicBarrier)
    private static void mostrarResultats() {
        System.out.println("Suma: " + suma.get());
        System.out.println("Mitjana: " + mitjana.get());
        System.out.println("Desviació estàndard: " + desviacio.get());
    }
}