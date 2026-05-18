# Aplicación de modelos de lenguaje de proteínas (pLMs) para descifrar los dialectos moleculares de extremófilos
Este repositorio contiene el proyecto realizado como parte del trabajo de la asignatura de Prácticas del Máster de Bioinformática y Biología Computacional en la Universidad Autónoma de Madrid, promoción del 2024. /p
El objetivo principal del trabajo ha sido el desarrollo y validación de un modelo predictivo basado en secuencias proteicas, en el contexto del uso de modelos de lenguaje de proteínas (pLMs), para identificar posibles patrones moleculares asociados a secuencias que codifican enzimas procedentes de organismos extremófilos.
Los pasos seguidos para el desarrollo de este proyecto han sido los siguientes:
- Depuración e integración de datos
- Análisis de similitud de secuencias
- Desarrollo del modelo predictivo (pLMs)
- Análisis estructural

# Estructura del trabajo
```
│   LICENSE
│   README.md
│
├───0_Tablas_iniciales
│       Tabla_extremofilos.xlsx
│       Tabla_PETasas.xlsx
│
├───1_SSN
│   ├───archivos_usados
│   │       PETasas_totales_FASTA.fa
│   │       PETasas_totales_pim.xlsx
│   │
│   ├───figuras
│   │       PETasas_totales_leyenda.png
│   │
│   ├───scripts
│   │       SSN.ipynb
│   │       ssnHeuristic.py
│   │
│   └───ssn_heuristic_test_total
│           cytoscape_network.cys
│           net_single.cx2
│           net_single.net
│           net_single.net.txt
│
├───2_XGBoost
│   ├───mapa_predicciones
│   │   ├───scripts
│   │   │   │   mapa_predicciones.html
│   │   │   │   mapa_predicciones.qmd
│   │   │   └───mapa_predicciones_files
│   │   └───tabla
│   │           Tabla_PETasas_con_predicciones.xlsx
│   │
│   ├───scripts
│   │       Kmer_PETases.ipynb
│   │       XGBoost.ipynb
│   │
│   └───tablas_usadas
│           PETases_kmers_combo.xlsx
│           PETases_kmers_uniprot.xlsx
│           progreso_grid_search.csv
│           uniprotkb_PETases.xlsx
│
└───3_AlphaFold
    ├───Actinomadura craniellae
    │   └───resultados
    ├───Herbidospora galbida
    │   └───resultados
    ├───Stutzerimonas stutzeri
    │   └───resultados
    ├───Thermobifida halotolerans
    │   └───resultados
    └───_figuras
            comp_prot1.png
```
            comp_prot2.png
            comp_prot3.png
