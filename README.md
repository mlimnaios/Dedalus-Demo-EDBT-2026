# Dedalus - Quantum Join-Order Optimizer (Demo)

DEDALUS aims to provide a next-generation platform that offers the best of both classical and quantum worlds, effectively partitioning big data algorithms into parts solvable by classical or quantum computing, combining the advantages of both technologies.

![Dedalus Logo](/assets/dedalus-logo.png)

## Requirements

- **Docker Desktop** (or Docker Engine + Compose) ([install here](https://docs.docker.com/install/))
- ~4 GB free disk space
- Ports **5001** and **8888** available on your machine

## Quick Start

### 1. Pull the image

```bash
docker image pull marksterg/dedalus-demo:latest
```

### 2. Start the containers

```bash
docker compose up --build pg-sampledb demo jupyter
```

> The first build takes ~2 minutes.

- The demo ships with only a sample database (`pg-sampledb`), for simplicity. You can also include the full [JOB/IMDB benchmark](https://github.com/gregrahn/join-order-benchmark) dataset:

  ```bash
  docker compose up --build pg-job pg-sampledb demo jupyter
  ```

> The JOB dataset setup takes ~5 minutes (download + initialization).

Wait until you see log output settling and the services report they are **ready**. Then open:

| Interface | URL |
| --- | --- |
| Web UI | <http://localhost:5001> |
| Jupyter Notebook | <http://localhost:8888> |

- **Web UI**

  1. Open <http://localhost:5001>
  2. Select a query file from the dropdown
  3. Select a solver fromt the dropdown menu
  4. Click **Run**

  Results will show:

  - The join graph and table cardinalities (query analysis metadata)
  - The QUBO solver output and the recommended join tree
  - Execution times for PostgreSQL's default plan vs. the quantum-enhanced (Dedalus) plan

- **Jupyter Notebook Demos**

  Open <http://localhost:8888> and run `notebooks/demo.ipynb`. The notebook walks through the same pipeline step by step:

  1. Configure the pipeline via `PipelineConfig`
  2. Analyze the query and build the QUBO formulation
  3. Run the solver (simulated_annealing by default)
  4. Compare PostgreSQL plans and measure speedup

## Configuration

The pipeline is controlled by a JSON config. **You do not need to edit this to get started** (the defaults work with the sample database out of the box).

```jsonc
{
  "database": {
    "host": "pg-job",                           // Database host (e.g., localhost, or Docker service name)
    "port": 5432,                               // Database port
    "user": "postgres",                         // Database username
    "password": "postgres",                     // Database password
    "name": "job"                               // Database name
  },
  "solver": {
    "backend": "dwave",                         // Solver backend (dwave, qiskit)
    "solver": "simulated_annealing",            // Specific backend's solver algorithm
    "solver_opts": {"mode": "dwave"},           // Solver-specific options
    "weight_mode": "cardinality",               // Weight calculation mode for building QUBO weights
    "cardinality_type": "unfiltered",           // Cardinality type (relevant only when weight_mode=cardinality)
    "run_mode": "normal",                       // Execution mode
    "explain_format": "txt",                    // Query plan format (txt or json)
    "verbose": false,                           // Enable verbose logging intermediate results
    "export": true,                             // Export results to directory
    "normalize_weights": true,                  // Normalize weights
    "normalize_after_pruning": true             // Normalize weights after pruning
  },
  "query": {
    "sql": null,                                // Inline SQL query (alternative to file_path)
    "file_path": "db/job/queries/5rel/2c.sql",  // Path to query file
    "output_dir": "output"                      // Output directory for results
  }
}
```

### Database Hosts

When connecting from **inside Docker** (demo/webapp, notebook), use the container hostname with port **5432**:

- `pg-sampledb:5432` - Sample database
- `pg-job:5432` - IMDB database

When connecting from **outside Docker** (your host machine), use localhost with the mapped host ports:

- `localhost:5433` - Sample database
- `localhost:5434` - IMDB database

## Hardware QPU Access (Optional)

> **Skip this section** unless you have a D-Wave Leap account and want to run queries on real quantum hardware.

1. Copy the example config:

   ```bash
   cp configs/dwave/dwave-example.conf configs/dwave/dwave.conf
   ```

2. Add your API token to `configs/dwave/dwave.conf`.

3. In the UI or notebook, select a QPU solver (e.g. `Advantage2_system1.12`).

## Stopping and Restarting

```bash
# Stop all containers (data is preserved)
docker compose down

# Restart from where you left off
docker compose up pg-sampledb demo jupyter
```

---

## Troubleshooting

- **Browser shows "connection refused" on port 5001 or 8888**

  The containers may still be starting. Wait 30–60 seconds after the logs settle and try again.

- **Port already in use**

  Another process is using port 5001 or 8888. Stop that process, or edit `docker-compose.yml` to map to different host ports.

- **`docker compose` command not found**

  Older Docker versions use `docker-compose` (with a hyphen) instead of `docker compose`.
