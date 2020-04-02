pragma Singleton
import Felgo 3.0
import QtQuick 2.0

Item {
  id: constants

  // create on your own license key on https://www.felgo.com/license
  readonly property string licenseKey: "065E29B6BAE2B7392216C5CFFCFD92B6D994CBA522164FF7F68A43EAE17F0B0D4C4744FA50779E4C5A904765762499EF5B2CE6A680EF69B702419CB6E0DD8D6FCDD47F012092E977986A65B0F71CE043E9E825BDAC0249F7F9368C922D10AB86CBBFD8D58DEBE3966C3B08B1D6A0BAE68C409AC660D061C4D6557F99E9DDB6430E8851F9173DADBF8B38AD44407ADD6AC806747572995F5146948C2FAFCAA6CE52237DD8BDFECD1CEECAC0E78FBA86A2E0B9073F3C404B4ACC3AA3242734852F53B5CDB5305C7ACA57FF9AF9FE711F8B642B98A20C57EB454958C9CD5BBAC48EC8D17BF57D0AEB559E87BA31F0B63425251C69E84FF4C894B8B8545E08979E6BF6CEBBB6546A7C8F9FCDFA49E9D1DE3BF3D0BA2C8E5DCB5FE187A2AFBB2DBF26BD868F4EC5A6AD3313E5AA1B03407001D474D9000DBD995DD22627006359B9AC6A494DFE63D57130B3D93868358EE650325C1776AC9670F746C13D764776E98F05FF76AD27BBE728732D510CB10614FED89F4DD40333C7E27880E8ADBE0AF07C6FB749DC153AC17AD4DF534DEF212349"

  // FelgoGameNetwork - set your own gameId and secret after you created your own game here: https://cloud.felgo.com/
  readonly property int gameId: 844
  readonly property string gameSecret: "stuggi_corona_hackaton_2020"

  // FelgoMultiplayer - set your own appKey and pushKey after you created your own game here: https://cloud.felgo.com/
  readonly property string appKey: "c2e647ce-5a83-4153-ae62-5c7d349ba87e"
  readonly property string pushKey: "JYnG49n8sI5wXsTcdTx8XDZXSefAEaivUMcdMLUl@cI7t1EIp6AYi7qFhY9CdACyYlVpxqlHPZeeqZF4X"

  // game configuration
  readonly property bool enableStoreAndAds: false // whether in-game store and ads are enabled, if set to false the game is 100% free to play
  readonly property bool simulateStore: false     // if the store should be simulated locally or actually use the soomla plugin to purchase goods
  readonly property bool lockScreenForInterstitial: false // locks screen to prevent user-action while interstitial is opening up
}
