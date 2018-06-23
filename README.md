# Dart Web Experiments

## Running an experiment

Run the following command:

```bash
$> webdev serve <experiment>
```

For example,

```bash
$> webdev serve bliss_on_tap
```

## Adding a new experiment

To add a new experiment called "new_experiment":

1. Create a new top-level directory called `new_experiment`.

1. Inside this new directory, create `index.html`, `main.dart`, and any other necessary files for the web page.

1. Update `build.yaml` with a new `target:` for the experiment:

```yaml
  new_experiment:
    sources: [new_experiment/**]
    builders:
        build_web_compilers|entrypoint:
            generate_for: [new_experiment/main.dart]
```