# Aplicación de modelos de lenguaje de proteínas (pLMs) para descifrar los dialectos moleculares de extremófilos
Este repositorio contiene el proyecto desarrollado como parte de la asignatura de Prácticas del Máster de Bioinformática y Biología Computacional en la Universidad Autónoma de Madrid (curso 2024-2026).

El objetivo principal del trabajo ha sido el desarrollo y validación de un modelo predictivo basado en secuencias proteicas, en el contexto del uso de modelos de lenguaje de proteínas (pLMs), para identificar posibles patrones moleculares asociados a secuencias que codifican enzimas procedentes de organismos extremófilos.

---

## Flujo de trabajo
Las etapas realizadas en este proyecto fueron:
1. Depuración e integración de datos
2. Análisis de similitud de secuencias (SSN)
3. Desarrollo del modelo predictivo mediante pLMs y XGBoost
4. Análisis estructural 

---

## Estructura del trabajo

```
├───0_Tablas_iniciales
│       Tabla_extremofilos.xlsx
│       Tabla_PETasas.xlsx
├───1_SSN
│   ├───archivos_usados
│   │       PETasas_totales_FASTA.fa
│   │       PETasas_totales_pim.xlsx
│   ├───figuras
│   │       PETasas_totales.png
│   ├───scripts
│   │       SSN.ipynb
│   │       ssnHeuristic.py
│   └───ssn_heuristic_test_total     # Resultados de la red de similitud de secuencias (SSN)
│           cytoscape_network.cys    
│           net_single.cx2           
│           net_single.net           
│           net_single.net.txt       
├───2_XGBoost
│   ├───mapa_predicciones    
│   │   ├───scripts
│   │   │   │   mapa_predicciones.html
│   │   │   │   mapa_predicciones.qmd
│   │   │   └───mapa_predicciones_files
│   │   └───tabla
│   │           Tabla_PETasas_con_predicciones.xlsx
│   ├───scripts
│   │       Kmer_PETases.ipynb  # Vectorización de las secuencias en k-mers
│   │       XGBoost.ipynb       # Desarrollo del modelo predictivo
│   └───tablas_usadas
│           PETases_kmers_combo.xlsx
│           PETases_kmers_uniprot.xlsx
│           progreso_grid_search.csv
│           uniprotkb_PETases.xlsx
└───3_Analisis_Estructural
    ├───Actinomadura_craniellae    # Candidato Termófilo
    │   └───resultados
    ├───Herbidospora_galbida       # Candidato Termófilo
    │   └───resultados
    ├───Stutzerimonas_stutzeri     # Extremo-tolerante
    │   └───resultados
    ├───Thermobifida_halotolerans  # Candidato Termófilo
    │   └───resultados
    └───_figuras                   # Figuras generadas en la comparactiva estructural
            comp_prot1.png
            comp_prot2.png
            comp_prot3.png
 ```

## Herramientas y entornos
Este trabajo se ha realizado principalmente en Python (v3.10) utilizando entornos de Jupyter Notebook. El mapa de preddiciones se realizó en R (v 4.4.1) mediante un documento Quarto (`.qmd`). 

El resto de paquetes necesarios para reproducir los análisis se encuentran especificados en los archivos:

- ´requirements.txt` -> paquetes de Python
- ´requirements_R.txt` -> paquete de R

---

## Ejecutar el proyecto

1. Clonar el repositorio

```bash
git clone URL
```

2. Instalar paquetes de Python

```bash
pip install -r requirements.txt
```

3. Instalar paquetes de R

```r
install.packages(readLines("requirements_R.txt"))
```

4. Ejecutar los notebooks en orden:
   - `1_SSN`
       - `SSN.ipynb`
       - `ssnHeuristic.py`
   - `2_XGBoost`
       - `Kmer_PETases.ipynb`
       - ´XGBoost.ipynb`
       - `mapa_predicciones.qmd`

--- 

