package reduce

import (
	"bytes"
	"io/ioutil"
	"net/http"
	"testing"

	"github.com/phR0ze/cyberlinux/cli/internal/aur"
	"github.com/stretchr/testify/assert"
)

const (
	gAurLinuxRes = `{
  "version":5,
  "type":"multiinfo",
  "resultcount":1,
  "results":[
    {
      "ID":648306,
      "Name":"yay",
      "PackageBaseID":115973,
      "PackageBase":"yay",
      "Version":"9.3.1-1",
      "Description":"Yet another yogurt. Pacman wrapper and AUR helper written in go.",
      "URL":"https://github.com/Jguer/yay",
      "NumVotes":795,
      "Popularity":57.679582,
      "OutOfDate":null,
      "Maintainer":"jguer",
      "FirstSubmitted":1475688004,
      "LastModified":1569007205,
      "URLPath":"/cgit/aur.git/snapshot/yay.tar.gz",
      "Depends":["pacman>=5.1.0","pacman<=5.1.3","sudo","git"],
      "MakeDepends":["go"],
      "License":["GPL"],
      "Keywords":["arm","AUR","go","helper","pacman","wrapper","x86"]
    }
  ]
}`
)

// Implemente the http.Transport interface for http testing
// -------------------------------------------------------------------------------------------------
type RoundTripFunc func(req *http.Request) *http.Response

func (f RoundTripFunc) RoundTrip(req *http.Request) (*http.Response, error) {
	return f(req), nil
}

func TestInfo(t *testing.T) {
	reset()

	reduce, err := newReduce(AurClientOpt(aur.New(aur.ClientOpt(&http.Client{
		Transport: RoundTripFunc(func(req *http.Request) *http.Response {
			return &http.Response{
				StatusCode: 200,
				Body:       ioutil.NopCloser(bytes.NewBufferString(gAurLinuxRes)),
				Header:     make(http.Header),
			}
		}),
	}))))

	assert.Nil(t, err)
	assert.NotNil(t, reduce)
}
