# YAML Best Practices

## Basic Rules

1. **Use 2 spaces** for indentation (never tabs)
2. **No trailing whitespace**
3. **Newline at end of file**
4. **Consistent key ordering** within same level

## Formatting

### Lists

```yaml
# Good - hyphen with space
items:
  - first
  - second
  - third

# Bad - no space after hyphen
items:
  -first
  -second
```

### Newlines After Headers

```yaml
# Good - newline after document separator
---

name: example

# Good - newline after key before list
tasks:

  - name: first task
    command: echo "hello"

  - name: second task
    command: echo "world"
```

### Code Blocks

Always specify language type:

```yaml
# Good
script: |
  ```bash
  #!/bin/bash
  echo "Hello"
  ```

# Better for literal blocks
script: |
  #!/bin/bash
  echo "Hello"
```

## Strings

```yaml
# Simple strings don't need quotes
name: example

# Use quotes for:
# - Leading/trailing spaces
name: " example "

# - Special characters
path: "@/home/user"

# - Numbers as strings
version: "1.0"

# - Booleans as strings
enabled: "true"

# Multi-line strings
description: |
  This is a long description
  that spans multiple lines.
  
  With paragraphs.

# Folded strings (newlines become spaces)
summary: >
  This is a long line
  that will be folded
  into a single line.
```

## Booleans

```yaml
# Good - lowercase
enabled: true
disabled: false

# Avoid these variants
ENABLED: True
disabled: FALSE
enabled: yes
disabled: no
```

## Numbers

```yaml
# Integers
count: 42
port: 8080

# Floats
version: 1.0
pi: 3.14159

# Strings that look like numbers
code: "01234"  # Leading zero
pin: "1234"    # Preserve as string
```

## Anchors and Aliases

```yaml
# Define anchor
defaults: &defaults
  timeout: 30
  retries: 3

# Use alias
production:
  <<: *defaults
  url: https://api.prod.com

development:
  <<: *defaults
  url: https://api.dev.com
  timeout: 60  # Override
```

## Comments

```yaml
# Document header comment
---

# Section comment
database:
  # Inline explanation
  host: localhost  # Default host
  port: 5432
```

## Common Patterns

### Configuration Files

```yaml
# Good structure
---

# Application Configuration
app:
  name: myapp
  version: 1.0.0

# Database Settings
database:
  host: ${DB_HOST:-localhost}
  port: ${DB_PORT:-5432}
  name: ${DB_NAME:-myapp}

# Logging Configuration
logging:
  level: info
  format: json
  
  # Outputs
  outputs:
    - type: console
      level: debug
      
    - type: file
      path: /var/log/myapp.log
      level: info
```

### GitHub Actions

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          npm install
          npm test
```

### Docker Compose

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

## Validation

Use yamllint for validation:

```bash
# Install
pip install yamllint

# Check file
yamllint config.yml

# With custom config
yamllint -c .yamllint.yml .
```

Example `.yamllint.yml`:

```yaml
---

extends: default

rules:
  line-length:
    max: 120
  comments:
    min-spaces-from-content: 2
  indentation:
    spaces: 2
```

## Common Mistakes

```yaml
# Bad - inconsistent indentation
items:
  - name: first
     value: 1  # 3 spaces

# Bad - no space after colon
name:value

# Bad - trailing spaces
name: value   

# Bad - tabs instead of spaces
items:
	- first

# Bad - missing newline at EOF
last: line
```