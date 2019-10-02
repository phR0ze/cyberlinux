// Package model provides a single arch model for other packages
package model

import (
	"encoding/json"
	"time"
)

// Package details encapsulating AUR packages and PKGBUILD
type Package struct {
	ID             int       `json:"ID"`             // AUR.ID
	Name           string    `json:"Name"`           // AUR.Name, PKGBUILD.pkgname
	Arch           string    `json:"Arch"`           // PKGBUILD.arch
	PackageBaseID  int       `json:"PackageBaseID"`  // AUR.PackageBaseID,
	PackageBase    string    `json:"PackageBase"`    // AUR.PackageBase,
	Version        string    `json:"Version"`        // AUR.Version, PKGBUILD.pkgver
	Release        int       `json:"Release"`        // PKGBUILD.pkgrel
	Description    string    `json:"Description"`    // AUR.Description, PKGBUILD.pkgdesc
	URL            string    `json:"URL"`            // AUR.URL, PKGBUILD.url
	NumVotes       int       `json:"NumVotes"`       // AUR.NumVotes,
	Popularity     float64   `json:"Popularity"`     // AUR.Popularity,
	OutOfDate      bool      `json:"OutOfDate"`      // AUR.OutOfDate,
	Maintainer     string    `json:"Maintainer"`     // AUR.Maintainer,
	FirstSubmitted time.Time `json:"FirstSubmitted"` // AUR.FirstSubmitted,
	LastModified   time.Time `json:"LastModified"`   // AUR.LastModified,
	URLPath        string    `json:"URLPath"`        // AUR.URLPath,
	Depends        []string  `json:"Depends"`        // AUR.Depends, PKGBUILD.depends
	MakeDepends    []string  `json:"MakeDepends"`    // AUR.MakeDepends, PKGBUILD.makedepends
	CheckDepends   []string  `json:"CheckDepends"`   // AUR.CheckDepends,
	Conflicts      []string  `json:"Conflicts"`      // AUR.Conflicts,
	Provides       []string  `json:"Provides"`       // AUR.Provides,
	Replaces       []string  `json:"Replaces"`       // AUR.Replaces,
	OptDepends     []string  `json:"OptDepends"`     // AUR.OptDepends, PKGBUILD.optdepends
	Groups         []string  `json:"Groups"`         // AUR.Groups,
	License        []string  `json:"License"`        // AUR.License, PKGBUILD.license
	Keywords       []string  `json:"Keywords"`       // AUR.Keywords,
	Source         []string  `json:"Source"`         // PKGBUILD.source
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
