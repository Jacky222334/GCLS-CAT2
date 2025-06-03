# GCLS Zahlen-fokussiertes Mermaid (ohne Test Run)

## 🔢 **Nur Zahlen - horizontales Mermaid**

```mermaid
flowchart LR
    A["1161<br/>Database"] --> B["1146<br/>Letter sent"]
    B --> C["52<br/>Letter response"]
    C --> D["111<br/>+59 Email response"]
    D --> E["153<br/>+42 SMS response"]
    E --> F["293<br/>+140 Final"]
```

## 📊 **Mit Response Rates:**

```mermaid
flowchart LR
    A["1161<br/>individuals"] --> B["1146<br/>Letter"]
    B --> C["52<br/>(4.5%)"]
    C --> D["111<br/>(9.6%)"]
    D --> E["153<br/>(13.2%)"]
    E --> F["293<br/>(25.2%)"]
```

## 🎯 **Kompakt mit Methoden:**

```mermaid
flowchart LR
    A[1161] --> B["Letter<br/>1146→52"]
    B --> C["Email<br/>+59→111"]
    C --> D["SMS<br/>+42→153"]
    D --> E["Final<br/>+140→293"]
```

## 📈 **Kumulative Entwicklung:**

```mermaid
flowchart LR
    A["Start<br/>1161"] --> B["Wave 1<br/>52"]
    B --> C["Wave 2<br/>111"]
    C --> D["Wave 3<br/>153"]
    D --> E["Final<br/>293"]
```

## 🔄 **Ultra-clean:**

```mermaid
flowchart LR
    A[1161] --> B[52] --> C[111] --> D[153] --> E[293]
``` 