import Felgo 3.0
import QtQuick 2.0
import "../common"
import "../interface"

SceneBase {
  id: storeScene

  readonly property bool simulateStore: Constants.simulateStore // set this to true on desktop to allow testing the feature without actual store access
  readonly property int tokens: simulateStore ? simulatedTokens.balance : tokenCurrency.balance

  // dummy item for testing purposes to simulate a working store plugin (plugin not available on desktop)
  Item {
    id: simulatedTokens
    property int balance: 0
  }

  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: storeScene.gameWindowAnchorItem
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  // token info
  TokenInfo {
    id: tokenInfo
    tokens: storeScene.tokens
    anchors.right: gameWindowAnchorItem.right
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 20
    onClicked: {
      tokenTimerText.visible = true
    }
  }

  // token remaining time info
  Text {
    id: tokenTimerText
    text: gameTokensEarnedPerDay + " free token\nin "+remainingTime
    color: "white"
    font.family: standardFont.name
    font.pixelSize: 10
    horizontalAlignment: Text.AlignHCenter
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10
    anchors.top: tokenInfo.bottom
    anchors.topMargin: 10
    visible: false
    onVisibleChanged: if(visible) tokenTimerText.timeUntilBonus = getTimeUntilBonus()
    width: 75

    property var timeUntilBonus: getTimeUntilBonus()
    property string remainingTime: timeUntilBonus.hours + "h "+ timeUntilBonus.minutes + "m " + timeUntilBonus.seconds + "s"

    // timer to show and update remaining time info
    Timer {
      interval: 100
      running: tokenTimerText.visible
      repeat: true
      property int count: 0
      onRunningChanged: if(running) count = 0
      onTriggered: {
        if(count >= 50)
          tokenTimerText.visible = false

        tokenTimerText.timeUntilBonus = getTimeUntilBonus()
        count++
        menuScene.checkDailyBonus() // check for daily bonus
      }
    }
  }

  // UI
  Column {
    id: buttonCol
    anchors.centerIn: parent
    spacing: 10

    // generate rows for products with repeater
    Repeater {
      model: store.currencyPacks

      delegate: Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        // product
        Text {
          text: modelData.name
          width: 95
          font.family: standardFont.name
          color: "white"
          anchors.verticalCenter: parent.verticalCenter
        }

        // price
        Text {
          text: modelData.purchaseType.marketPriceAndCurrency
          width: 60
          font.family: standardFont.name
          color: "white"
          anchors.verticalCenter: parent.verticalCenter
        }

        // buy button
        ButtonBase {
          text: "Buy Now"
          width: buttonText.contentWidth + 50
          anchors.verticalCenter: parent.verticalCenter
          onClicked: {
            if(simulateStore) {
              // simulate buying of product
              storeScene.giveTokens(modelData.currencyAmount)
              store.itemPurchased(modelData.itemId)
            }
            else {
              // trigger actual purchase
              store.buyItem(modelData.itemId)

              storeScene.sendPurchaseEvent("IAP.OpenNativeBuyDialog", modelData)
            }
          }
        }
      }
    } // repeater

    ButtonBase {
      id: watchButton
      text: "Watch Video (+" + gameTokenEarnedPerVideoWatch + " Token)"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: {
         // show interstitial without opening menu and force ad even if enough tokens
        adMobInterstitial.displayInterstitial(false, true, "storeScene")
      }
    }

    // ad description
    Text {
      text: "No advertisements are shown if you have "+gameTokenNoAdsLimit+" tokens or more."
      font.family: standardFont.name
      font.pixelSize: 10
      color: "white"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    ButtonBase {
      id: backButton
      text: "Back"
      anchors.horizontalCenter: parent.horizontalCenter
      onClicked: backButtonPressed()
    }
  } // column

  // timer to first show daily free tokens without user action
  Timer {
    id: autoShowDailyTimer
    interval: 1000
    onTriggered: {
      tokenInfo.startAnimation()
      tokenTimerText.visible = true
    }
  }

  // dialog for successful purchase
  OnuDialog {
    id: purchaseSuccessDialog
    width: 250
    _internalScale: 0.5
    backgroundTargetItem: gameWindowAnchorItem // background will fill whole screen
    title: "Purchase Successful"
    description: ""
    options: ["Ok"]
    visible: false
    onOptionSelected: {
      tokenInfo.startAnimation()
      visible = false
    }
  }

  // store for purchasing
  Store {
    id: store

    version: 1
    secret: Constants.soomlaSecret
    androidPublicKey: Constants.soomlaAndroidKey

    // Virtual currencies within the game
    currencies: [
      Currency {
        id: tokenCurrency
        itemId: Constants.currencyId
        name: "Tokens"
      }
    ]

    // Purchasable token packs
    currencyPacks: [
      // 100 tokens pack
      CurrencyPack {
        id: token100Pack
        itemId: Constants.currency100PackId
        name: "100 Tokens"
        description: "Buy 100 Tokens"
        currencyId: tokenCurrency.itemId
        currencyAmount: 100
        purchaseType:  StorePurchase { id: token100Purchase; productId: token100Pack.itemId; price: 1.0 }
      },
      // 500 tokens pack
      CurrencyPack {
        id: token500Pack
        itemId: Constants.currency500PackId
        name: "500 Tokens"
        description: "Buy 500 Tokens"
        currencyId: tokenCurrency.itemId
        currencyAmount: 500
        purchaseType:  StorePurchase { id: token500Purchase; productId: token500Pack.itemId; price: 2.0 }
      },
      // 1000 tokens pack
      CurrencyPack {
        id: token1000Pack
        itemId: Constants.currency1000PackId
        name: "1000 Tokens"
        description: "Buy 1000 Tokens"
        currencyId: tokenCurrency.itemId
        currencyAmount: 1000
        purchaseType:  StorePurchase { id: token1000Purchase; productId: token1000Pack.itemId; price: 3.0 }
      },
      // 5000 tokens pack
      CurrencyPack {
        id: token5000Pack
        itemId: Constants.currency5000PackId
        name: "5000 Tokens"
        description: "Buy 5000 Tokens"
        currencyId: tokenCurrency.itemId
        currencyAmount: 5000
        purchaseType:  StorePurchase { id: token5000Purchase; productId: token5000Pack.itemId; price: 5.0 }
      }
    ]

    // show dialog on successful purchase
    onItemPurchased: {
      console.debug("Purchased item:", itemId)
      for(var idx in store.currencyPacks) {
        var pack = store.currencyPacks[idx]
        if(pack.itemId === itemId) {
          purchaseSuccessDialog.description = pack.currencyAmount+" tokens were added to your balance."
          purchaseSuccessDialog.visible = true
          storeScene.sendPurchaseEvent("IAP.Purchased", pack)
          return
        }
      }
    }

   onStorePurchaseCanceled: {
     console.debug("Canceled store purchase:", itemId)
     for(var idx in store.currencyPacks) {
       var pack = store.currencyPacks[idx]
       if(pack.itemId === itemId) {
         storeScene.sendPurchaseEvent("IAP.PurchaseCanceled", pack)
         return
       }
     }
   }

   onStorePurchaseStarted: {
     console.debug("Started store purchase:", itemId)
     for(var idx in store.currencyPacks) {
       var pack = store.currencyPacks[idx]
       if(pack.itemId === itemId) {
         storeScene.sendPurchaseEvent("IAP.PurchaseStarted", pack)
         return
       }
     }
   }
  }// Store

  // convenienc function to send additional data to flurry like the currency and local price
  function sendPurchaseEvent(name, pack) {
    flurry.logEvent(name, {"currencyAmount": pack.currencyAmount, "marketPriceAndCurrency": pack.purchaseType.marketPriceAndCurrency})
  }

  function takeTokens(amount) {
    if(amount <= 0) {
      console.log("Invalid Amount for takeTokens(): "+amount)
      return
    }

    // tokens may not be negative!
    if(storeScene.tokens < amount)
      amount = storeScene.tokens // will set tokens to zero

    if(amount > 0) {
      // take tokens
      if(simulateStore)
        simulatedTokens.balance -= amount
      else
        store.takeItem(tokenCurrency.itemId, amount)
    }
    else if(amount < 0) {
      giveTokens(amount * -1) // give tokens to reset them to zero! (no negative token balance possible)
    }
  }

  function giveTokens(amount) {
    if(amount <= 0) {
      console.log("Invalid amount for giveTokens(): "+amount)
      return
    }

    if(simulateStore)
      simulatedTokens.balance += amount
    else {
      // can either be gameTokensEarnedByDay or gameTokensEarnedPerVideoWatch - useful to analyze what is called how often
      flurry.logEvent("IAP.GiveTokens", "currencyAmount", amount)
      store.giveItem(tokenCurrency.itemId, amount)
    }
  }

  function enterScene() {
    tokenTimerText.visible = false
    autoShowDailyTimer.start()
  }
}
