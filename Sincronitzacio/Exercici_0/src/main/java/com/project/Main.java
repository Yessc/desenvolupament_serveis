package com.project;

import java.util.Map;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicLong;

public class Main {

    // Guarda els resultats parcials de cada microservei (thread-safe)
    private static final ConcurrentHashMap<Integer, Integer> resultats = new ConcurrentHashMap<>();

    // Per calcular el temps total d'execució
    private static final AtomicLong inici = new AtomicLong();

    public static void main(String[] args) {

        inici.set(System.nanoTime());

        // Barrera que espera 3 microserveis
        CyclicBarrier barrera = new CyclicBarrier(3, () -> {
            System.out.println("\n=== Tots els microserveis han finalitzat ===");
            combinarResultats();
        });

        // Pool amb 3 fils
        ExecutorService executor = Executors.newFixedThreadPool(3);

        // Llançament dels microserveis
        for (int i = 1; i <= 3; i++) {
            executor.submit(crearMicroservei(i, barrera));
        }

        // Tancament controlat
        executor.shutdown();
        try {
            if (!executor.awaitTermination(15, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }

    /**
     * Crea un microservei simulat com a Runnable.
     * Cada microservei:
     * 1. Espera un temps aleatori inicial
     * 2. Processa dades
     * 3. Genera un resultat parcial
     * 4. Espera a la barrera
     */
    private static Runnable crearMicroservei(int id, CyclicBarrier barrera) {

        return () -> {
            try {

                // Retard inicial (simula latència de xarxa)
                int esperaInicial = ThreadLocalRandom.current().nextInt(200, 600);
                Thread.sleep(esperaInicial);
                System.out.println("Microservei " + id +
                        " iniciant processament (latència: " + esperaInicial + "ms)");

                // Temps de processament
                int tempsProcessament = ThreadLocalRandom.current().nextInt(800, 1400);
                System.out.println("Microservei " + id +
                        " processant dades... (" + tempsProcessament + "ms)");
                Thread.sleep(tempsProcessament);

                // Simulació de càlcul (treball determinista)
                int iniciRang = id * 50;
                int parcial = 0;
                for (int i = iniciRang; i < iniciRang + 20; i++) {
                    parcial += i;
                }

                // Guardem el resultat parcial
                resultats.put(id, parcial);

                System.out.println("Microservei " + id +
                        " finalitzat. Resultat parcial = " + parcial);

                // Espera fins que tots arribin
                barrera.await();

            } catch (InterruptedException | BrokenBarrierException e) {
                System.err.println("Error al microservei " + id + ": " + e.getMessage());
                Thread.currentThread().interrupt();
            }
        };
    }

    /**
     * Combina els resultats parcials en un resultat final.
     * Aquest mètode és executat automàticament per la CyclicBarrier.
     */
    private static void combinarResultats() {

        int sumaTotal = resultats.values()
                .stream()
                .mapToInt(Integer::intValue)
                .sum();

        long tempsTotal = TimeUnit.NANOSECONDS
                .toMillis(System.nanoTime() - inici.get());

        System.out.println("\nResultats parcials: " + resultats);
        System.out.println("Resultat FINAL agregat: " + sumaTotal);
        System.out.println("Temps total d'execució: " + tempsTotal + " ms");
    }
}