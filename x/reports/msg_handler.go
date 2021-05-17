package reports

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	reportstypes "github.com/desmos-labs/desmos/x/staging/reports/types"
	juno "github.com/desmos-labs/juno/types"

	"github.com/desmos-labs/djuno/x/posts/types"

	desmosdb "github.com/desmos-labs/djuno/database"
)

// HandleMsg handles a message properly
func HandleMsg(tx *juno.Tx, msg sdk.Msg, db *desmosdb.DesmosDb) error {
	if len(tx.Logs) == 0 {
		return nil
	}

	desmosMsg, ok := msg.(*reportstypes.MsgReportPost)
	if ok {
		return handleMsgReport(tx, desmosMsg, db)
	}

	return nil
}

// handleMsgReport allows to handle a MsgReportPost properly
func handleMsgReport(tx *juno.Tx, msg *reportstypes.MsgReportPost, db *desmosdb.DesmosDb) error {
	return db.SaveReport(types.NewReport(
		reportstypes.NewReport(
			msg.PostID,
			msg.ReportType,
			msg.Message,
			msg.User,
		),
		tx.Height,
	))
}
