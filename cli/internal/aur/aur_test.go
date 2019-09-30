package aur

import (
	"bytes"
	"io/ioutil"
	"net/http"
	"net/url"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	yayRes = `{
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
	multipleRes = `{
  "version":5,
  "type":"multiinfo",
  "resultcount":2,
  "results":[
    {
      "ID":600377,
      "Name":"pacaur",
      "PackageBaseID":139631,
      "PackageBase":"pacaur",
      "Version":"4.8.6-1",
      "Description":"An AUR helper that minimizes user interaction",
      "URL":"https:\/\/github.com\/E5ten\/pacaur",
      "NumVotes":28,"Popularity":2.954984,
      "OutOfDate":null,
      "Maintainer":"E5ten",
      "FirstSubmitted":1550162333,
      "LastModified":1554160585,
      "URLPath":"\/cgit\/aur.git\/snapshot\/pacaur.tar.gz",
      "Depends":["auracle-git","expac","sudo","git","jq"],
      "MakeDepends":["perl","git"],
      "License":["ISC"],
      "Keywords":[]
	},
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
	searchRes = `{"version":5,"type":"search","resultcount":8,"results":[{"ID":650203,"Name":"pikaur-git","PackageBaseID":129630,"PackageBase":"pikaur-git","Version":"1.5.2-2","Description":"AUR helper which asks all questions before installing\/building. Inspired by pacaur, yaourt and yay.","URL":"https:\/\/github.com\/actionless\/pikaur","NumVotes":14,"Popularity":0.028185,"OutOfDate":null,"Maintainer":"actionless","FirstSubmitted":1517379650,"LastModified":1569503346,"URLPath":"\/cgit\/aur.git\/snapshot\/pikaur-git.tar.gz"},{"ID":650205,"Name":"pikaur","PackageBaseID":131064,"PackageBase":"pikaur","Version":"1.5.2-2","Description":"AUR helper which asks all questions before installing\/building. Inspired by pacaur, yaourt and yay.","URL":"https:\/\/github.com\/actionless\/pikaur","NumVotes":145,"Popularity":9.156593,"OutOfDate":null,"Maintainer":"actionless","FirstSubmitted":1521935919,"LastModified":1569503354,"URLPath":"\/cgit\/aur.git\/snapshot\/pikaur.tar.gz"},{"ID":648306,"Name":"yay","PackageBaseID":115973,"PackageBase":"yay","Version":"9.3.1-1","Description":"Yet another yogurt. Pacman wrapper and AUR helper written in go.","URL":"https:\/\/github.com\/Jguer\/yay","NumVotes":795,"Popularity":57.485695,"OutOfDate":null,"Maintainer":"jguer","FirstSubmitted":1475688004,"LastModified":1569007205,"URLPath":"\/cgit\/aur.git\/snapshot\/yay.tar.gz"},{"ID":648309,"Name":"yay-bin","PackageBaseID":117489,"PackageBase":"yay-bin","Version":"9.3.1-1","Description":"Yet another yogurt. Pacman wrapper and AUR helper written in go. Pre-compiled.","URL":"https:\/\/github.com\/Jguer\/yay","NumVotes":74,"Popularity":5.281192,"OutOfDate":null,"Maintainer":"jguer","FirstSubmitted":1480777574,"LastModified":1569007393,"URLPath":"\/cgit\/aur.git\/snapshot\/yay-bin.tar.gz"},{"ID":650996,"Name":"yay-git","PackageBaseID":129573,"PackageBase":"yay-git","Version":"9.3.1.r3.g5b3ae06-1","Description":"Yet another yogurt. Pacman wrapper and AUR helper written in go. (development version)","URL":"https:\/\/github.com\/Jguer\/yay","NumVotes":14,"Popularity":1.170067,"OutOfDate":null,"Maintainer":"tuckerboniface","FirstSubmitted":1517205142,"LastModified":1569750778,"URLPath":"\/cgit\/aur.git\/snapshot\/yay-git.tar.gz"},{"ID":650242,"Name":"ffpb","PackageBaseID":145346,"PackageBase":"ffpb","Version":"0.2.0-2","Description":"A progress bar for ffmpeg. Yay !","URL":"https:\/\/github.com\/althonos\/ffpb","NumVotes":0,"Popularity":0,"OutOfDate":null,"Maintainer":"SleeplessSloth","FirstSubmitted":1569459159,"LastModified":1569514631,"URLPath":"\/cgit\/aur.git\/snapshot\/ffpb.tar.gz"},{"ID":544072,"Name":"puyo","PackageBaseID":135895,"PackageBase":"puyo","Version":"1.0-1","Description":"A frontend for pacman and yay.","URL":"https:\/\/github.com\/Appadeia\/puyo","NumVotes":4,"Popularity":0.012081,"OutOfDate":null,"Maintainer":"appadeia","FirstSubmitted":1536534050,"LastModified":1536985328,"URLPath":"\/cgit\/aur.git\/snapshot\/puyo.tar.gz"},{"ID":630294,"Name":"pak-config-yay","PackageBaseID":143592,"PackageBase":"pak-config-yay","Version":"1.0-4","Description":"A pacman config for yay","URL":"https:\/\/gitlab.com\/moussaelianarsen\/pak","NumVotes":1,"Popularity":0.524426,"OutOfDate":null,"Maintainer":"Arsen6331","FirstSubmitted":1563247238,"LastModified":1563378393,"URLPath":"\/cgit\/aur.git\/snapshot\/pak-config-yay.tar.gz"}]}`
	emptyRes  = `{"version": 5, "type": "multiinfo", "resultcount": 0, "results": []}`
)

// Implemente the http.Transport interface for http testing
// -------------------------------------------------------------------------------------------------
type RoundTripFunc func(req *http.Request) *http.Response

func (f RoundTripFunc) RoundTrip(req *http.Request) (*http.Response, error) {
	return f(req), nil
}

// Create a new API client with optional transport override
func newAPI(fns ...RoundTripFunc) (api *API) {
	if len(fns) > 0 {
		api = New(ClientOpt(&http.Client{
			Transport: RoundTripFunc(fns[0]),
		})).(*API)
	} else {
		api = New().(*API)
	}
	return
}

func TestSearch(t *testing.T) {
	api := newAPI(func(req *http.Request) *http.Response {
		assert.Equal(t, url.Values{"arg": []string{"yay"}, "type": []string{"search"}, "v": []string{"5"}}, req.URL.Query())

		// Send back mock response
		return &http.Response{
			StatusCode: 200,

			// Send response to be tested
			Body: ioutil.NopCloser(bytes.NewBufferString(searchRes)),

			// Must be set to non-nil value or it panics
			Header: make(http.Header),
		}
	})

	pkgs, err := api.Search("yay")
	assert.Nil(t, err)
	assert.Len(t, pkgs, 8)
	assert.Equal(t, "pikaur-git", pkgs[0].Name)
	assert.Equal(t, "pikaur", pkgs[1].Name)
	assert.Equal(t, "yay", pkgs[2].Name)
	assert.Equal(t, "yay-bin", pkgs[3].Name)
	assert.Equal(t, "yay-git", pkgs[4].Name)
	assert.Equal(t, "ffpb", pkgs[5].Name)
	assert.Equal(t, "puyo", pkgs[6].Name)
	assert.Equal(t, "pak-config-yay", pkgs[7].Name)
}

func TestInfoMultiple(t *testing.T) {
	api := newAPI(func(req *http.Request) *http.Response {
		assert.Equal(t, url.Values{"arg[]": []string{"yay", "pacaur"}, "type": []string{"info"}, "v": []string{"5"}}, req.URL.Query())

		// Send back mock response
		return &http.Response{
			StatusCode: 200,

			// Send response to be tested
			Body: ioutil.NopCloser(bytes.NewBufferString(multipleRes)),

			// Must be set to non-nil value or it panics
			Header: make(http.Header),
		}
	})

	pkgs, err := api.Info("yay", "pacaur")
	assert.Nil(t, err)
	assert.Len(t, pkgs, 2)
	assert.Equal(t, 600377, pkgs[0].ID)
	assert.Equal(t, "pacaur", pkgs[0].Name)
	assert.Equal(t, 139631, pkgs[0].PackageBaseID)
	assert.Equal(t, "pacaur", pkgs[0].PackageBase)
	assert.Equal(t, "4.8.6-1", pkgs[0].Version)
	assert.Equal(t, "An AUR helper that minimizes user interaction", pkgs[0].Description)
	assert.Equal(t, "https://github.com/E5ten/pacaur", pkgs[0].URL)
	assert.Equal(t, 28, pkgs[0].NumVotes)
	assert.Equal(t, 2.954984, pkgs[0].Popularity)
	assert.Equal(t, false, pkgs[0].OutOfDate)
	assert.Equal(t, "E5ten", pkgs[0].Maintainer)
	assert.Equal(t, "2019-02-14 09:38:53 -0700 MST", pkgs[0].FirstSubmitted.String())
	assert.Equal(t, "2019-04-01 17:16:25 -0600 MDT", pkgs[0].LastModified.String())
	assert.Equal(t, "/cgit/aur.git/snapshot/pacaur.tar.gz", pkgs[0].URLPath)
	assert.Equal(t, []string{"auracle-git", "expac", "sudo", "git", "jq"}, pkgs[0].Depends)
	assert.Equal(t, []string{"perl", "git"}, pkgs[0].MakeDepends)
	assert.Equal(t, []string(nil), pkgs[0].CheckDepends)
	assert.Equal(t, []string(nil), pkgs[0].Conflicts)
	assert.Equal(t, []string(nil), pkgs[0].Provides)
	assert.Equal(t, []string(nil), pkgs[0].Replaces)
	assert.Equal(t, []string(nil), pkgs[0].OptDepends)
	assert.Equal(t, []string(nil), pkgs[0].Groups)
	assert.Equal(t, []string{"ISC"}, pkgs[0].License)
	assert.Equal(t, []string{}, pkgs[0].Keywords)

	assert.Equal(t, 648306, pkgs[1].ID)
	assert.Equal(t, "yay", pkgs[1].Name)
	assert.Equal(t, 115973, pkgs[1].PackageBaseID)
	assert.Equal(t, "yay", pkgs[1].PackageBase)
	assert.Equal(t, "9.3.1-1", pkgs[1].Version)
	assert.Equal(t, "Yet another yogurt. Pacman wrapper and AUR helper written in go.", pkgs[1].Description)
	assert.Equal(t, "https://github.com/Jguer/yay", pkgs[1].URL)
	assert.Equal(t, 795, pkgs[1].NumVotes)
	assert.Equal(t, 57.679582, pkgs[1].Popularity)
	assert.Equal(t, false, pkgs[1].OutOfDate)
	assert.Equal(t, "jguer", pkgs[1].Maintainer)
	assert.Equal(t, "2016-10-05 11:20:04 -0600 MDT", pkgs[1].FirstSubmitted.String())
	assert.Equal(t, "2019-09-20 13:20:05 -0600 MDT", pkgs[1].LastModified.String())
	assert.Equal(t, "/cgit/aur.git/snapshot/yay.tar.gz", pkgs[1].URLPath)
	assert.Equal(t, []string{"pacman>=5.1.0", "pacman<=5.1.3", "sudo", "git"}, pkgs[1].Depends)
	assert.Equal(t, []string{"go"}, pkgs[1].MakeDepends)
	assert.Equal(t, []string(nil), pkgs[1].CheckDepends)
	assert.Equal(t, []string(nil), pkgs[1].Conflicts)
	assert.Equal(t, []string(nil), pkgs[1].Provides)
	assert.Equal(t, []string(nil), pkgs[1].Replaces)
	assert.Equal(t, []string(nil), pkgs[1].OptDepends)
	assert.Equal(t, []string(nil), pkgs[1].Groups)
	assert.Equal(t, []string{"GPL"}, pkgs[1].License)
	assert.Equal(t, []string{"arm", "AUR", "go", "helper", "pacman", "wrapper", "x86"}, pkgs[1].Keywords)
}

func TestInfoSingle(t *testing.T) {
	api := newAPI(func(req *http.Request) *http.Response {
		assert.Equal(t, url.Values{"arg[]": []string{"yay"}, "type": []string{"info"}, "v": []string{"5"}}, req.URL.Query())

		// Send back mock response
		return &http.Response{
			StatusCode: 200,

			// Send response to be tested
			Body: ioutil.NopCloser(bytes.NewBufferString(yayRes)),

			// Must be set to non-nil value or it panics
			Header: make(http.Header),
		}
	})

	pkgs, err := api.Info("yay")
	assert.Nil(t, err)
	assert.Len(t, pkgs, 1)
	assert.Equal(t, 648306, pkgs[0].ID)
	assert.Equal(t, "yay", pkgs[0].Name)
	assert.Equal(t, 115973, pkgs[0].PackageBaseID)
	assert.Equal(t, "yay", pkgs[0].PackageBase)
	assert.Equal(t, "9.3.1-1", pkgs[0].Version)
	assert.Equal(t, "Yet another yogurt. Pacman wrapper and AUR helper written in go.", pkgs[0].Description)
	assert.Equal(t, "https://github.com/Jguer/yay", pkgs[0].URL)
	assert.Equal(t, 795, pkgs[0].NumVotes)
	assert.Equal(t, 57.679582, pkgs[0].Popularity)
	assert.Equal(t, false, pkgs[0].OutOfDate)
	assert.Equal(t, "jguer", pkgs[0].Maintainer)
	assert.Equal(t, "2016-10-05 11:20:04 -0600 MDT", pkgs[0].FirstSubmitted.String())
	assert.Equal(t, "2019-09-20 13:20:05 -0600 MDT", pkgs[0].LastModified.String())
	assert.Equal(t, "/cgit/aur.git/snapshot/yay.tar.gz", pkgs[0].URLPath)
	assert.Equal(t, []string{"pacman>=5.1.0", "pacman<=5.1.3", "sudo", "git"}, pkgs[0].Depends)
	assert.Equal(t, []string{"go"}, pkgs[0].MakeDepends)
	assert.Equal(t, []string(nil), pkgs[0].CheckDepends)
	assert.Equal(t, []string(nil), pkgs[0].Conflicts)
	assert.Equal(t, []string(nil), pkgs[0].Provides)
	assert.Equal(t, []string(nil), pkgs[0].Replaces)
	assert.Equal(t, []string(nil), pkgs[0].OptDepends)
	assert.Equal(t, []string(nil), pkgs[0].Groups)
	assert.Equal(t, []string{"GPL"}, pkgs[0].License)
	assert.Equal(t, []string{"arm", "AUR", "go", "helper", "pacman", "wrapper", "x86"}, pkgs[0].Keywords)
}

func TestInfoError(t *testing.T) {
	api := newAPI(func(req *http.Request) *http.Response {
		return &http.Response{
			StatusCode: http.StatusServiceUnavailable,
			Body:       ioutil.NopCloser(bytes.NewBufferString("503")),
			Header:     make(http.Header),
		}
	})

	pkg, err := api.Info("yay")
	assert.Equal(t, "Failed request to AUR: 503", err.Error())
	assert.Len(t, pkg, 0)
}

func TestInfoEmpty(t *testing.T) {
	api := newAPI(func(req *http.Request) *http.Response {
		return &http.Response{
			StatusCode: 200,
			Body:       ioutil.NopCloser(bytes.NewBufferString(emptyRes)),
			Header:     make(http.Header),
		}
	})

	pkg, err := api.Info("yay")
	assert.Nil(t, err)
	assert.Len(t, pkg, 0)
}

func TestInfoNoPackagesGiven(t *testing.T) {
	api := newAPI(func(req *http.Request) *http.Response {
		return &http.Response{
			StatusCode: 200,
			Body:       ioutil.NopCloser(bytes.NewBufferString(emptyRes)),
			Header:     make(http.Header),
		}
	})

	pkg, err := api.Info()
	assert.Equal(t, "Failed to get info for zero packages", err.Error())
	assert.Len(t, pkg, 0)
}
