package com.project;

import java.util.concurrent.*;

public class Exercici1 {
    public static void main(String[] args) {
        ExecutorService executor = Executors.newFixedThreadPool(3);
        ConcurrentHashMap<String, Double> dadesCompartides = new ConcurrentHashMap<>();

        executor.execute(new OperacioBancaria(dadesCompartides));
        executor.execute(new CalculInteressos(dadesCompartides));

        Future<String> futurResultat = executor.submit(new ConsultaFinal(dadesCompartides));

        try {
            System.out.println(futurResultat.get());
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        }

        executor.shutdown();
        try {
            if (!executor.awaitTermination(5, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
        }
    }
}

class OperacioBancaria implements Runnable {
    private final ConcurrentHashMap<String, Double> dades;

    public OperacioBancaria(ConcurrentHashMap<String, Double> dades) {
        this.dades = dades;
    }

    @Override
    public void run() {
        dades.put("saldo", 1000.0);
        System.out.println("[SISTEMA] Recepció d'operació bancària: 1000.0€ registrats.");
    }
}

class CalculInteressos implements Runnable {
    private final ConcurrentHashMap<String, Double> dades;

    public CalculInteressos(ConcurrentHashMap<String, Double> dades) {
        this.dades = dades;
    }

    @Override
    public void run() {
        try {
            Thread.sleep(500);
            dades.computeIfPresent("saldo", (clau, valor) -> valor + (valor * 0.05));
            System.out.println("[SISTEMA] Càlcul d'interessos (5%) aplicat correctament.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

class ConsultaFinal implements Callable<String> {
    private final ConcurrentHashMap<String, Double> dades;

    public ConsultaFinal(ConcurrentHashMap<String, Double> dades) {
        this.dades = dades;
    }

    @Override
    public String call() throws Exception {
        Thread.sleep(1000);
        Double saldoFinal = dades.getOrDefault("saldo", 0.0);
        return "OPERACIÓ FINALITZADA - Saldo actualitzat del client: " + saldoFinal + "€";
    }
}