# Open Fibre Data Standard (OFDS) Guide

## Introduction

The Open Fibre Data Standard (OFDS) is a common language for describing terrestrial fibre optic networks. It provides a standardised approach for publishing, exchanging, analysing and visualising fibre network information.

## OFDS Components

| Component            | Purpose                                                                                         |
| -------------------- | ----------------------------------------------------------------------------------------------- |
| Schema and Codelists | Defines the structure of OFDS data, field definitions, permissible values and validation rules. |
| Documentation        | Guidance, primer material, implementation instructions and reference documentation.             |
| Open Source Tools    | Software for converting, validating, exploring and publishing OFDS data.                        |


## OFDS Data Categories

| Category            | Examples                                                                       |
| ------------------- | ------------------------------------------------------------------------------ |
| Location Data       | Fibre routes, cable paths, tower locations, Points of Presence (PoPs), IXPs    |
| Technical Data      | Capacity, fibre specifications, resilience characteristics, power availability |
| Administrative Data | Ownership, operators, infrastructure status, dark fibre availability           |

These categories are intended to answer three questions:

- Where is the infrastructure?
- What are its characteristics?
- Who owns or operates it?

## Key Terminology

### Field
A field is the basic unit of information in OFDS.

If you think of a CSV spreadsheet:

| node\_id | name | latitude | longitude |
| -------- | ---- | -------- | --------- |

Each column is a field. Fields contain either:

- Location data
- Attribute data

### Location Data
Location data describes where infrastructure exists. Examples:

- Node coordinates
- Fibre routes
- Tower locations
- Cable landing stations

Typically represented using geographic coordinates or GIS geometries.

### Attribute Data
Attribute data describes characteristics of infrastructure. Examples:

- Owner
- Capacity
- Status
- Fibre type
- Dark fibre availability

These are the values typically shown in a map popup or GIS attribute table

### Node
A point within a fibre network. Examples include:

- Point of Presence (PoP)
- Internet Exchange Point (IXP)
- Tower
- Cable landing station
- Data centre

Think of a node as a significant location where the network begins, ends or interconnects.

### Span
A physical fibre connection between two nodes. A span represents the actual route followed by fibre infrastructure.

### Endpoint
The start and end nodes connected by a span.

### Network
A collection of interconnected nodes and spans. A network may represent:

- One operator's network
- A government backbone
- A national fibre map
- A regional aggregation of multiple operators

A network acts as the container for fibre infrastructure objects.

### Node and Span Relationship

```mermaid
flowchart LR
    N1[Node 1] <-- Span --> N2[Node 2]
```

### Example Network

```mermaid
flowchart LR
    B[Brisbane PoP] -->|Span| S[Sydney PoP]
    S -->|Span| M[Melbourne IXP]
```

## Provider Terminology

### Physical Infrastructure Provider
A physical infrastructure provider owns passive assets such as:

- Fibre
- Ducts
- Poles
- Towers
- Facilities

OFDS distinguishes the physical layer from higher service layers. 

### Network Provider
A network provider may operate services across physical infrastructure.

This distinction becomes important when ownership and operation differ.

## OFDS Objects You Will Commonly Encounter
When working with KML-to-OFDS conversions, QGIS, or the OFDS web validator, the objects you encounter most often are:

| Object       | Description                   |
| ------------ | ----------------------------- |
| Network      | Container for infrastructure  |
| Node         | Point feature                 |
| Span         | Line feature                  |
| Organisation | Owner or operator             |
| Location     | Geographic coordinates        |
| Identifier   | Unique ID                     |
| Geometry     | GIS representation            |
| Attributes   | Metadata about infrastructure |

These form the basis of almost every OFDS dataset.

## OFDS and GIS

| OFDS Concept | GIS Equivalent |
|-------------|---------------|
| Node | Point Feature |
| Span | Line Feature |
| Network | Layer or Dataset |
| Attribute | Table Column |
| Geometry | Shape |

This mapping is often the easiest way for new users to understand OFDS.

## Useful References

- Official OFDS documentation: https://standard.ofds.info/
- OFDS project site: https://ofds.info/en/
- Internet Society overview: https://www.internetsociety.org/blog/2025/04/the-open-fibre-data-standard/
