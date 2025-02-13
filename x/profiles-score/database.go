package profilesscore

import (
	"github.com/desmos-labs/djuno/v2/types"
	"github.com/desmos-labs/djuno/v2/x/profiles"
)

type Database interface {
	profiles.Database
	SaveApplicationLinkScore(score *types.ProfileScore) error
}
