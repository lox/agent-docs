# Go Best Practices

## Environment Setup

- Use **[hermit](https://cashapp.github.io/hermit/)** for Go version management
- Use **golangci-lint** for code quality
- Use **[kong](https://github.com/alecthomas/kong)** for CLI applications
- Use **task** for task management (`hermit install task`)

## Project Setup

```bash
# Initialize hermit environment
hermit init

# Install tools
hermit install go golangci-lint task

# Initialize Go module
go mod init github.com/lox/{project-name}
```

## Code Style

- Follow `gofmt` formatting
- Use `goimports` for import organization
- Prefer short, clear variable names
- Use receiver names consistently (1-2 letters)

## Error Handling

```go
// Good
if err != nil {
    return fmt.Errorf("failed to process: %w", err)
}

// Avoid
if err != nil {
    log.Fatal(err)
}
```

## Struct Design

- Use embedding for composition
- Keep interfaces small and focused
- Place interfaces near usage, not definition

## Testing

- Use table-driven tests
- Test behavior, not implementation
- Use `testify/assert` for assertions

```go
func TestFunction(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"case1", "input1", "output1"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Function(tt.input)
            assert.Equal(t, tt.expected, result)
        })
    }
}
```

## CLI with Kong

```go
type CLI struct {
    Debug bool `help:"Enable debug mode"`
    Command struct {
        Run RunCmd `cmd:"" help:"Run the service"`
    } `cmd:""`
}

func main() {
    var cli CLI
    ctx := kong.Parse(&cli)
    ctx.Run()
}
```

## Dependencies

- Use `go mod tidy` regularly
- Pin major versions in go.mod
- Avoid deep dependency trees

## Concurrency

- Use channels for communication
- Prefer `sync.WaitGroup` for coordination or [errgroup](https://pkg.go.dev/golang.org/x/sync/errgroup) for when things get more complicated

- Always handle context cancellation

```go
func worker(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    case <-time.After(time.Second):
        // do work
    }
    return nil
}
```

## Hermit Usage

Shell hooks typically provide correct PATH. If needed:
- One-time activation: `. bin/activate-hermit`
- Direct command access: `bin/go version`

## Common Commands

```bash
# Setup with hermit
hermit install go
hermit install task

# Task management
task build
task test
task lint

# Direct commands
golangci-lint run
go test ./...
go build -o bin/app ./cmd/app
```
