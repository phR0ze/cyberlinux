package aur

import (
	"encoding/json"
	"time"
)

// API response object
type gAPIRes struct {
	Error       string    `json:"error"`
	Version     int       `json:"version"`
	Type        string    `json:"type"`
	ResultCount int       `json:"resultcount"`
	Results     []Package `json:"results"`
}

// Package details
type Package struct {
	ID             int       `json:"ID"`
	Name           string    `json:"Name"`
	PackageBaseID  int       `json:"PackageBaseID"`
	PackageBase    string    `json:"PackageBase"`
	Version        string    `json:"Version"`
	Description    string    `json:"Description"`
	URL            string    `json:"URL"`
	NumVotes       int       `json:"NumVotes"`
	Popularity     float64   `json:"Popularity"`
	OutOfDate      bool      `json:"OutOfDate"`
	Maintainer     string    `json:"Maintainer"`
	FirstSubmitted time.Time `json:"FirstSubmitted"`
	LastModified   time.Time `json:"LastModified"`
	URLPath        string    `json:"URLPath"`
	Depends        []string  `json:"Depends"`
	MakeDepends    []string  `json:"MakeDepends"`
	CheckDepends   []string  `json:"CheckDepends"`
	Conflicts      []string  `json:"Conflicts"`
	Provides       []string  `json:"Provides"`
	Replaces       []string  `json:"Replaces"`
	OptDepends     []string  `json:"OptDepends"`
	Groups         []string  `json:"Groups"`
	License        []string  `json:"License"`
	Keywords       []string  `json:"Keywords"`
}

// UnmarshalJSON override to convert json primitives into Package types
func (pkg *Package) UnmarshalJSON(data []byte) (err error) {

	// Define a new alias to our type to only get properties and not functions to
	// avoid infinite recursion of adding the UnmarshalJSON override function.
	type Alias Package

	// Define a new struct with override properties that inherits from the original
	alias := &struct {
		FirstSubmitted int `json:"FirstSubmitted"`
		LastModified   int `json:"LastModified"`
		*Alias
	}{
		Alias: (*Alias)(pkg),
	}

	// Now unmarshal the data as per normal
	if err = json.Unmarshal(data, alias); err != nil {
		return
	}

	// Now convert the json types into our package types
	pkg.FirstSubmitted = time.Unix(int64(alias.FirstSubmitted), 0)
	pkg.LastModified = time.Unix(int64(alias.LastModified), 0)

	return
}
