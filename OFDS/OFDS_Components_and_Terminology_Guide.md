# Open Fibre Data Standard (OFDS) Guide

## Introduction

The Open Fibre Data Standard (OFDS) is a common language for describing terrestrial fibre optic networks. It provides a standardised approach for publishing, exchanging, analysing and visualising fibre network information.

## OFDS Components

```mermaid
flowchart LR
    A[OFDS] --> B[Schema and Codelists]
    A --> C[Documentation]
    A --> D[Open Source Tools]
```

## OFDS Data Categories

```mermaid
flowchart TD
    A[OFDS Data] --> B[Location Data]
    A --> C[Technical Data]
    A --> D[Administrative Data]
```

## Key Terminology

### Node
A point within a network such as a PoP, IXP, tower or cable landing station.

### Span
A physical fibre connection between two nodes.

### Endpoint
The start and end nodes connected by a span.

### Network
A collection of interconnected nodes and spans.

## Node and Span Relationship

```mermaid
flowchart LR
    N1[Node 1] <-- Span --> N2[Node 2]
```

## Example Network

```mermaid
flowchart LR
    B[Brisbane PoP] -->|Span| S[Sydney PoP]
    S -->|Span| M[Melbourne IXP]
```

## OFDS and GIS

| OFDS Concept | GIS Equivalent |
|-------------|---------------|
| Node | Point Feature |
| Span | Line Feature |
| Network | Layer or Dataset |
| Attribute | Table Column |
| Geometry | Shape |

## Why Mermaid

Mermaid is generally the better choice for GitHub documentation because it renders natively in GitHub, remains editable as text, works well with version control, and avoids maintaining separate image files.
