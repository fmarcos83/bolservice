PDFDocument = require 'pdfkit'
base64 = require 'base64-stream'
middleware = (data, res) ->
  if data.blind
    data.shiptocontact = undefined
    data.shipto = undefined
    data.customerpo = undefined
    data.shiptocontact = undefined
    data.bolNumber = undefined
    data.mdtpo = undefined
    data.carriername = undefined
    data.pickupnumber = undefined
    data.material = undefined
  data = data
  fs = require 'fs'
  margin = 20
  width = 572
  height = 752
  options =
    info:
      Producer: 'mediathread'
      Creator: 'mediathread'
    margin: margin

  doc = new PDFDocument options
  doc.font './fonts/Roboto-Thin.ttf'
  res.contentType('application/pdf')
  if data.download
    doc.pipe(base64.encode())
       .pipe res
  else
    doc.pipe res
  fontSize = 12
  doc.fontSize fontSize
  doc.fillColor "black"
  #HEADER
  header = ->
    cacheFontSize = doc.fontSize()
    doc.fontSize 15
       .text 'BILL OF LADING',
          align: 'center'
          width: width
    doc.moveUp()
    doc.fontSize 13
       .text 'Page 1 of __________',
          align: 'right'
          width: width - 10
    doc.fontSize cacheFontSize
    lineHorizontal 41

  #BORDER
  border = ->
    doc.moveTo 0,0
      .rect margin, margin, width, height
      .stroke()
  lineHorizontal = (yPos,wPos=undefined,start=undefined)->
    lineWidth = wPos ? width+margin
    doc.moveTo start ? margin ,yPos
       .lineTo lineWidth, yPos
       .stroke()

  lineVertical = (height, xPos, yPos)->
    lineHeight = yPos
    doc.moveTo xPos, yPos
       .lineTo xPos, height + yPos

  drawBox = (xPos, yPos, height, width,fill=false,color="#000",opacity=1)->
      res = doc.moveTo(0,0).rect xPos, yPos, width, height
      if not fill
          res.lineWidth 1.4
          res.stroke()
      if fill
          res.fillAndStroke color, color
          res.opacity opacity
      res.opacity 1
      res.fillAndStroke "#000", "#000"
      doc.lineWidth 1

  drawLabelInput = (label,text,xPos,yPos,fontsize=9,width=undefined)->
    fontsizeCached = doc.fontSize()
    doc.fillColor 'black'
    doc.fontSize fontsize
    doc.text "#{label}:  #{text}", xPos, yPos,
      width: width
    doc.fontSize fontsizeCached

  drawText = (text, xPos, yPos, width=undefined, fontsize=9, align="center", underline=false)->
    fontsizeCached = doc.fontSize()
    doc.fillColor 'black'
    doc.fontSize fontsize ? 9
    doc.text "#{text}", xPos, yPos,
      width: width
      align: align ? 'center'
      underline: underline ? false
    doc.fontSize fontsizeCached

  shipInfoFromText = ->
    shipFrom = data.shipfrom
    drawLabelInput "Name", shipFrom.name, 24, 52
    drawLabelInput "Address", shipFrom.address, 24, 63
    drawLabelInput "City/State/Zip", "#{shipFrom.city}, #{shipFrom.state} #{shipFrom.zip}", 24, 74
    drawLabelInput "SID#", "", 24, 85
    drawLabelInput "FOB", "", 280, 85
    drawCheckBox 302, 86, 9

  shipInfoToText = ->
    shipTo = data.shipto
    drawLabelInput "Name", "#{shipTo?.name ? ''}", 24, 112
    drawLabelInput "Address", "#{shipTo?.address ? ''}", 24, 123
    drawLabelInput "City/State/Zip", "#{shipTo?.city ? ''}, #{shipTo?.state ? ''} #{shipTo?.zip ? ''}", 24, 134
    drawLabelInput "CID#", "", 24, 145
    drawLabelInput "FOB", "", 280, 145
    drawCheckBox 302, 146, 9

  shipInfoChargesBillTo = ->
    drawLabelInput "Name", "", 24, 172
    drawLabelInput "Address", "", 24, 183
    drawLabelInput "City/State/Zip", "", 24, 194
    drawLabelInput "SPECIAL INSTRUCTIONS", "", 24, 210

  shipInfoRightInfo = ->
    drawLabelInput "Bill of Lading Number", "#{data.bolNumber ? ''}", 322, 42
    if data.carriername
      drawLabelInput "CARRIER NAME", "#{data.carriername ? ''}", 322, 100
    drawLabelInput "Pro number", "", 322, 140
    drawLabelInput "Freight Charge Terms", "", 322, 205
    doc.fillColor 'black'
    doc.fontSize 9
    underscore = "_____________"
    whiteSpace = "      "
    doc.text "Prepaid #{underscore}#{whiteSpace}Collect #{underscore}#{whiteSpace}3rdParty #{underscore}",322,220,
         width: 400
         columnGap: 5
         align: 'justify'
    drawLabelInput "Master Bill of Lading", "with attached underlying Bills of Lading", 390, 241,9, 140
    drawCheckBox 352, 245, 7
    drawText "(check box)", 330, 255, 50, 6


  drawCheckBox = (xPos, yPos, height)->
      doc.moveTo(0,0).rect xPos, yPos, height, height
         .lineWidth 1.4
         .stroke()
      doc.lineWidth 1

  drawHeader = (yPos, width, text)->
      drawBox(margin, yPos, 11, width-margin, true)
      cachedColor = doc.fillColor()
      doc.fillColor 'white'
      cachedFontsize = doc.fontSize()
      doc.fontSize 8
         .text text, margin, yPos,
           width: width
           align: 'center'
      doc.fillColor cachedColor
      doc.fontSize cachedFontsize

  drawBoxes = ->
      drawBox margin,617, 1, width, true#last empty box
      #direction top-down, left-right
      drawBox 285,402, 14, 307, true, "#292a2b", 1#1st box
      drawBox 55,602, 14, 45, true, "#292a2b", 1#2nd box
      drawBox 135,602, 14, 45, true, "#292a2b", 1#3th box
      drawBox 233,602, 14, 30, true, "#292a2b", 1#4th box
      drawBox 463,602, 14, 129, true, "#292a2b", 1#last box filled
      drawBox 340,617, 40, 252, false#last empty box

  drawHeaders = ->
      drawHeader 41, width/1.8, "SHIP FROM" #1st header
      drawHeader 101, width/1.8, "SHIP TO" #2nd header
      drawHeader 161, width/1.8, "THIRD PARTY FREIGHT CHARGES BILL TO:" #3th header
      drawHeader 267, width + margin, "CUSTOMER ORDER INFORMATION"  #4th header
      drawHeader 417, width + margin, "CARRIER INFORMATION" #5th header

  drawCheckBoxes = ->

  #SHIPMENT INFO
  shipmentInfo = ->
    lineHorizontal 100
    lineVertical 231,width/1.8,41
    #lineHorizontalLeft
    lineHorizontal 210, width/1.8
    #lineHorizontalRight
    lineHorizontal 140, undefined, width/1.8
    lineHorizontal 205, undefined, width/1.8
    lineHorizontal 240, undefined, width/1.8
  customerInfo = ->
    #vertical lines
    lineVertical 139,180,277
    lineVertical 139,232.5,277
    lineVertical 139,285,272
    lineVertical 124,350,277
    lineVertical 110,318.5,297
    #FILL THIS
    lineHorizontal 297#1st line
    lineHorizontal 312#2nd line
    lineHorizontal 327#3rd line
    lineHorizontal 342#4th line
    lineHorizontal 357#5th line
    lineHorizontal 372#6th line
    lineHorizontal 387#7th line
    lineHorizontal 402#8th line
    lineHorizontal 417#9th line

  customerOrderInfo = ->
      #CUSTOMER INFO COLUMN
      drawText "CUSTOMER ORDER NUMBER", margin, 277, 180
      drawText "MDT PO # #{data.mdtpo ? ''}", margin, 298, 180
      drawText "PICK UP # #{data.pickupnumber ? ''}", margin, 328, 180
      drawText "GRAND TOTAL", margin+4, 402, 180, undefined, "left"
      #PKGS COLUMN
      drawText "# PKGS", 180,277,52.5
      #WEIGHT COLUMN
      drawText "WEIGHT", 232.5,277,52.5
      drawText "Net", 232.5,313,52.5
      drawText "Weight", 232.5,328,52.5
      drawText "Gross", 232.5,343,52.5
      drawText "Weight", 232.5,358,52.5
      #PALLET/SLIP COLUMN
      drawText "PALLET/SLIP", 285,277,65
      drawText "(CIRCLE ONE)", 285,288,65, 6
      [0..7].map (index)->
          drawText "Y", 285, 298+index*15, 32.5
          drawText "N", 317.5, 298+index*15, 32.5
      #ADDITIONAL SHIPPER INFO
      drawText "ADDITIONAL SHIPPER INFO", 350,277,240

  carrierInfo = ->
    #vertical lines
    lineVertical 175,55,442
    lineVertical 190,100,427
    lineVertical 175,135,442
    lineVertical 190,180,427
    lineVertical 190,263,427

    lineVertical 190,232.5,427
    lineVertical 115,462.5,427
    lineVertical 115,462.5,427
    lineVertical 100,537.5,442
    lineVertical 45,462.5,572
    lineVertical 45,537.5,572
    #FILL THIS
    lineHorizontal 442, 180#CARRIER INFORMATION
    lineHorizontal 442, 462.5, width+margin#CARRIER INFORMATION
    lineHorizontal 427#CARRIER INFORMATION
    lineHorizontal 462#1st width line
    lineHorizontal 487#2st width line
    lineHorizontal 512#1st line
    lineHorizontal 527#2st line
    lineHorizontal 542#3st line
    lineHorizontal 557#4st line
    lineHorizontal 572#5st line
    lineHorizontal 587#6st line
    lineHorizontal 602#7st line
    lineHorizontal 617#8st line

  carrierOrderInfo = ->
      #HANDLING COLUMN
      drawText "HANDLING UNIT", margin, 427, 82.5
      drawText "QTY", margin, 441, 35
      drawText "TYPE", margin+35, 441, 45
      #PACKAGE COLUMN
      drawText "PACKAGE", 90, 427, 100
      drawText "QTY", 90, 441, 55
      drawText "TYPE", 90+45, 441, 45
      #WEIGHT COLUMN
      drawText "WEIGHT", 180, 441, 52
      drawText "H.M.", 222, 441, 52
      drawText "(X)", 222, 450, 52, 8
      #H.M COLUMN
      #COMMODITY COLUMN
      drawText "COMMODITY DESCRIPTION", 232.5, 427, 260
      drawText "Commodities requiring special or additional care or attention in handling or stwing must be so marked and packaged as to ensure safe transportation with ordinary care", 272.5, 440, 180, 4.8
      #drawText "#{data.material.id} #{data.material.description}", 232.5, 462, 260
      drawText "#{data?.material?.description ? ''}", 232.5, 462, 260
      drawText "GRAND TOTAL", 232.5, 602, 260
      #LTL COLUMN
      drawText "LTL ONLY", 462.5, 427, 140
      drawText "NMFC #", 462.5, 441, 75
      drawText "CLASS", 539.5, 441, 52
  footer = ->
    lineVertical 55,204,717
    lineVertical 40,340,677
    lineVertical 55,408,717
    lineHorizontal 657#8st line
    lineHorizontal 677#8st line
    lineHorizontal 717#8st line

  whiteSpace = (num)->
      space = [0..num].reduce (prev)->
         return prev+" "
      , ""

  footerInfo = ->
      underscore = "_______________________"
      #FIRST BOX TOP LEFT
      drawText "Where the rate is dependent on value, shippers are required to state specifically in writting the aggreed or declared value of the property as follows:", margin+4, 620, 300, 6, 'left'
      drawText "\"The agreed or declared value of the property is specifically stated by the shipper to be not exceeding #{underscore} per #{underscore}\"", margin+4, 638, 300, 6, 'left'
      #SECOND BOX TOP RIGHT
      drawText "COD Amount: $ ________________________________________",318, 620, 300

      drawText "Fee Terms:#{whiteSpace(5)} Collect: #{whiteSpace(20)} Prepaid: #{whiteSpace(20)} Customer check acceptable:",392, 634, 200, 8
      drawCheckBox 473+10, 637, 6
      drawCheckBox 544+10, 637, 6
      drawCheckBox 539+10, 647, 6
      #3rd BOX
      drawText "NOTE Liability Limitations for loss or damage in this shipment may be applicable. See 49 U.S.C 14706(c)(1)(A) and (B).", margin+4,662,width,undefined, 'left'
      #4th BOX MEDIUM LEFT
      drawText "RECEIVED, subject to individually determined rates or contracts that have been agreed upon in writing between the carrier and shipper, if applicable, otherwise to the rates, classifications and rules that have been established by the carrier and are available to the shipper, on request, and to all applicable state and federal regulations.", margin+4,677,310,7, 'left'
      #5th BOX MEDIUM RIGHT
      drawText "The carrier shall not make delivery of this shipment whitout payment of freight and all other lawful changes.", 340+4,677,240,7, 'left'
      drawText "_________________________________________________________ Shipper Signature", 340+4,706,240,7.5, 'left'
      #6th BOX BOTTOM LEFT
      drawText "SHIPPER SIGNATURE/DATE", margin+4, 717, 240, undefined, 'left'
      drawText "This is to certify that the above named materials are properly clasified, packaged, marked and labeled, and are in proper condition for transportation according to the applicable regulations of the DOT.", margin+4, 728, 180, 5, 'left'
      #7th BOX BOTTOM MEDIUM
      drawText "Trailer Loaded:", 204+4, 717, 240, 7, 'left', true
      drawText "Freight Counted:", 264+4, 717, 240, 7, 'left', true
      drawCheckBox 204+4, 730, 5
      drawText "By Shipper", 220, 728, 240, 7, 'left'
      drawCheckBox 204+4, 741, 5
      drawText "By Driver", 220, 739, 240, 7, 'left'
      drawCheckBox 264+4, 730, 5
      drawText "By Shipper", 280, 728, 240, 7, 'left'
      drawCheckBox 264+4, 741, 5
      drawText "By Driver/pallets said to contain", 280, 739, 240, 7, 'left'
      drawCheckBox 264+4, 752, 5
      drawText "By Driver/Pieces", 280, 750, 240, 7, 'left'
      #8th BOX BOTTOM RIGHT
      drawText "CARRIER SIGNATURE / PICKUP DATE", 412, 717, 240, undefined, 'left'
      drawText "Carrier acknowledges receipt of packages and required placecards. Carrier certifies emergency response information was made available and/or carrier has the DOT emergency response guidebook or equivalent documentation in the vehicle", 412, 728, 180, 5, 'left'

  #LAYOUT
  page = ->
    border()
    header()
    drawHeaders()
    shipmentInfo()
    #text for shipinfo
    shipInfoFromText()
    shipInfoToText()
    shipInfoChargesBillTo()
    shipInfoRightInfo()
    #end text for shipinfo
    customerInfo()
    #text for customerinfo
    customerOrderInfo()
    #end text for customerinfo
    carrierInfo()
    #text for carrier info
    carrierOrderInfo()
    #end text for carrier info
    footer()
    #text for footer info
    footerInfo()
    #end text for footer info
    drawBoxes()
  page()
  doc.end()
module.exports = middleware
