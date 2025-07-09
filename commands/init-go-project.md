# init-go-project

Initialize a new Go project with hermit tooling and best practices.

## Usage:
`/init-go-project [project-name]`

## Process:
1. Initialize hermit environment with `hermit init`
2. Install Go toolchain and development tools
3. Initialize Go module with github.com/lox/{project-name} pattern
4. Create basic project structure
5. Set up golangci-lint configuration
6. Create basic Taskfile.yml for common tasks

## Examples:
- `/init-go-project my-cli-tool`
- `/init-go-project auth-service`

## Output:
- Hermit environment configured
- Go module initialized
- Basic project structure created
- Development tools installed and configured

## Notes:
- Uses hermit for Go version management
- Follows github.com/lox/{name} module pattern
- Includes golangci-lint and task by default
- Creates standard Go project layout
