package aur

import (
	"github.com/phR0ze/cyberlinux/cli/internal/arch/model"
)

// API response object
type gAPIRes struct {
	Error       string          `json:"error"`
	Version     int             `json:"version"`
	Type        string          `json:"type"`
	ResultCount int             `json:"resultcount"`
	Results     []model.Package `json:"results"`
}
