# MCP Best Practices

Best practices for building Model Context Protocol (MCP) servers in Go using [mcp-go](https://github.com/mark3labs/mcp-go).

## Quick Start

```go
package main

import (
    "github.com/mark3labs/mcp-go/server"
    "github.com/mark3labs/mcp-go/transport/stdio"
)

func main() {
    s := server.NewMCPServer(
        "my-server",
        "1.0.0",
        server.WithToolCapabilities(true),
        server.WithResourceCapabilities(true, true),
    )

    // Add your tools and resources here

    transport := stdio.NewStdioServerTransport()
    s.Serve(transport)
}
```

## Core Concepts

### 1. Tools
Tools let LLMs perform actions through your server.

```go
s.AddTool(server.NewTool(
    "get_data",
    "Fetch data from the database",
    map[string]any{
        "type": "object",
        "properties": map[string]any{
            "id": map[string]any{"type": "string"},
        },
        "required": []string{"id"},
    },
), handler)
```

### 2. Resources
Resources provide data that LLMs can read.

```go
s.AddResource(server.NewResource(
    "config://app",
    "Application configuration",
    "application/json",
    map[string]any{"config": "data"},
))
```

### 3. Error Handling
Always return proper MCP errors:

```go
if err != nil {
    return nil, fmt.Errorf("operation failed: %w", err)
}
```

## Best Practices

1. **Keep it simple** - Start with basic functionality and iterate
2. **Use structured logging** - Help with debugging MCP interactions
3. **Validate inputs** - Always validate tool arguments
4. **Handle errors gracefully** - Return meaningful error messages
5. **Document your tools** - Clear descriptions help LLMs use them effectively

## Testing

Test your MCP server with the [MCP Inspector](https://github.com/modelcontextprotocol/inspector):

```bash
npx @modelcontextprotocol/inspector go run .
```
