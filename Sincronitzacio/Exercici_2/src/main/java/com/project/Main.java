package com.project;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Main{


       public static void main(String[] args) {

        int capacidad = 3;
        ParkingLot parking = new ParkingLot(capacidad);

        //poll para simulacion coches concurrentes
        ExecutorService executor = Executors.newCachedThreadPool();

        // Simulamos llegada 
        for (int i = 1; i <= 5; i++) {
            int id = i;

            try {
                // llegada aleatoria coches
                Thread.sleep(ThreadLocalRandom.current().nextInt(300, 800));
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }

            executor.submit(() -> parking.llegadaCoche(id));
        }

        executor.shutdown();
        try {
            executor.awaitTermination(30, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            executor.shutdownNow();
        }
    }
}

class ParkingLot {

    private final Semaphore semaphore;
    private final int capacidad;
    private final AtomicInteger cochesDentro = new AtomicInteger(0);

    public ParkingLot(int capacidad) {
        this.capacidad = capacidad;
        this.semaphore = new Semaphore(capacidad, true); // FIFO justo
    }

    public void llegadaCoche(int id) {

        System.out.println("El cotxe " + id + " ha arrivat.");

        // Si no hay plazas, avisamos
        if (semaphore.availablePermits() == 0) {
            System.out.println("Parking ple. Cotxe " + id + " Esperant.");
        }

        try {
            semaphore.acquire(); // el acquire le pide permiso al semaforo, si el parking esta lleno se bloquea el hilo hasta que se libere uno

            int dentro = cochesDentro.incrementAndGet();
            System.out.println("El cotxe "  + id + " ENTRA. Places ocupades: "
                    + dentro + "/" + capacidad);

            // Simula tiempo estacionado
            Thread.sleep(ThreadLocalRandom.current().nextInt(2000, 4000));

            dentro = cochesDentro.decrementAndGet();
            System.out.println("El cotxe " + id + " Surt. Places ocupades:  "
                    + dentro + "/" + capacidad);

            semaphore.release(); // Libera plaza para que otro coche pueda entrar

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
 