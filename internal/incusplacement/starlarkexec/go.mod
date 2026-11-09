// Nested module: packing tests import go.starlark.net here so the root
// go.mod/go.sum stay identical to the pinned provider derivative.
module github.com/NDDev-OpenNetwork/github-actions/internal/incusplacement/starlarkexec

go 1.27.1

require (
	github.com/NDDev-OpenNetwork/github-actions v0.0.0
	github.com/lxc/incus/v7 v7.6.0
	go.starlark.net v0.0.0-20261021141710-4f4267fb140d
)

require (
	github.com/sirupsen/logrus v1.10.2 // indirect
	go.yaml.in/yaml/v4 v4.0.0-rc.6 // indirect
	golang.org/x/sys v0.49.0 // indirect
	golang.org/x/term v0.47.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

replace github.com/NDDev-OpenNetwork/github-actions => ../../..
