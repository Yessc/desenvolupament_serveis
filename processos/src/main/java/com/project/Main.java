package com.project;

import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int opcio;

        do {
            System.out.println("\n--- MENÚ DE PROJECTE CONCURRÈNCIA ---");
            System.out.println("0. Exercici 0: Manteniment de Sistemes");
            System.out.println("1. Exercici 1: Operacions Bancàries");
            System.out.println("2. Exercici 2: Processament Web");
            System.out.println("3. Sortir");
            System.out.print("Selecciona una opció: ");
            
            while (!scanner.hasNextInt()) {
                System.out.print("Introdueix un número vàlid: ");
                scanner.next();
            }
            opcio = scanner.nextInt();

            // Passem un array buit per evitar errors de tipus
                        
                        
                        
                        
                        
                        
            String[] argsBuits = new String[0];

            switch (opcio) {
                case 0:
                    Exercici0.main(argsBuits);
                    break;
                case 1:
                    Exercici1.main(argsBuits);
                    break;
                case 2:
                    Exercici2.main(argsBuits);
                    break;
                case 3:
                    System.out.println("Sortint...");
                    break;
                default:
                    System.out.println("Opció no vàlida.");
            }
        } while (opcio != 3);

        scanner.close();
    }
}