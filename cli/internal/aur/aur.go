// Package aur provides support for some aur related functionality
//
// Includes an implemementation for the AUR REST API https://aur.archlinux.org/rpc.php
package aur

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"

	"github.com/phR0ze/n/pkg/opt"
	"github.com/pkg/errors"
)

const (
	gBaseURL = "https://aur.archlinux.org/rpc.php"
)

// Interface provides a related set of AUR functions
type Interface interface {
	Info(pkgs ...string) ([]Package, error) // Retrieves package details for the given packages
	Search(query string) ([]Package, error) // Search the aur for packages by name and/or description
}

// API client
type API struct {
	url    string       // base apiURL to use
	client *http.Client // http client to use
}

// New creates a new AUR API client
func New(opts ...*opt.Opt) Interface {
	url := DefaultBaseURLOpt(opts, gBaseURL)
	client := DefaultClientOpt(opts, http.DefaultClient)
	api := &API{url: url, client: client}
	return api
}

// Info retrieves package information for the given packages
func (api *API) Info(pkgs ...string) ([]Package, error) {
	if len(pkgs) == 0 {
		return nil, errors.Errorf("Failed to get info for zero packages")
	}

	values := &url.Values{}
	values.Set("type", "info")

	for _, pkg := range pkgs {
		values.Add("arg[]", pkg)
	}

	return api.get(values)
}

// Search retrieves package information for the given query term
func (api *API) Search(query string) ([]Package, error) {
	values := &url.Values{}
	values.Set("type", "search")
	values.Set("arg", query)

	return api.get(values)
}

// API gets like the examples from https://aur.archlinux.org/rpc.php
// info /rpc/?v=5&type=info&arg[]=foobar
// search /rpc/?v=5&type=search&arg=foobar
func (api *API) get(values *url.Values) (pkgs []Package, err error) {
	values.Set("v", "5")

	// Query API and check status
	var res *http.Response
	if res, err = api.client.Get(fmt.Sprintf("%s?%s", api.url, values.Encode())); err != nil {
		return
	}

	// Ensure the body is closed
	defer res.Body.Close()

	// Convert the response into result allowing status code to bubble up
	apiRes := gAPIRes{}
	decoder := json.NewDecoder(res.Body)
	err = decoder.Decode(&apiRes)
	if res.StatusCode != http.StatusOK {
		msg := "Failed request to AUR"

		// JSON response was not fully formed use status code
		if err != nil {
			err = errors.Errorf("%s: %v", msg, res.StatusCode)
			return
		}

		// Convert REST error into error
		if apiRes.Error != "" {
			err = errors.Errorf("%s: %s", msg, apiRes.Error)
			return
		}
	}

	// Set results
	pkgs = apiRes.Results

	return
}
