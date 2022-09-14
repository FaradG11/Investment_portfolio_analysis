WITH shares_data AS (
	SELECT 
		secid, 
		boardid,
		board_title,
		market_id,
		sectype,
		sectype_name,
		sectype_group, 
		shortname,
		secname, 
		latname,
		lotsize,
		decimals,
		faceunit,
		currencyid, 
		issuesize,
		prevprice AS prevprice_,
		prevdate AS prevdate_,
		open AS open_, 
		low AS low_, 
		high AS high_, 
		last AS last_, 
		bid AS bid_, 
		offer AS offer_, 
		spread AS spread_, 
		biddeptht, 
		offerdeptht, 
		lastchange, 
		lastchangeprcnt, 
		qty, 
		value, 
		value_usd, 
		numtrades, 
		voltoday, 
		valtoday, 
		valtoday_usd, 
		valtoday_rur,
		updatetime,
		CAST(NULL, 'Nullable(Decimal(9,2))') AS couponvalue, 
		CAST(NULL, 'Nullable(Decimal(9,2))') AS accruedint, 
		CAST(NULL, 'Nullable(Date)') AS nextcoupon,
		CAST(NULL, 'Nullable(Date)') AS matdate,
		CAST(NULL, 'Nullable(UInt16)') AS couponperiod,
		CAST(NULL, 'Nullable(Decimal(9,2))') AS buybackprice, 
		CAST(NULL, 'Nullable(Date)') AS buybackdate, 
		CAST(NULL, 'Nullable(Decimal(9,2))') AS couponpercent, 
		CAST(NULL, 'Nullable(Date)') AS offerdate,
		CAST(NULL, 'Nullable(UInt32)') AS duration 
	FROM {{ ref('shares') }}
),
bonds_data AS (
	SELECT 
		secid, 
		boardid,
		board_title,
		market_id,
		sectype,
		sectype_name,
		sectype_group, 
		shortname,
		secname, 
		latname,
		lotsize,
		decimals,
		faceunit,
		currencyid, 
		issuesize,
		lotvalue*(prevprice/100) as prevprice_,
		prevdate as prevdate_,
		lotvalue*(open/100) as open_, 
		lotvalue*(low/100) AS low_, 
		lotvalue*(high/100) AS high_, 
		lotvalue*(last/100) AS last_, 
		lotvalue*(bid/100) AS bid_, 
		lotvalue*(offer/100) AS offer_, 
		lotvalue*(spread/100) AS spread_, 
		biddeptht, 
		offerdeptht, 
		lastchange, 
		lastchangeprcnt, 
		qty, 
		value, 
		value_usd, 
		numtrades, 
		voltoday, 
		valtoday, 
		valtoday_usd, 
		valtoday_rur,
		updatetime,
		couponvalue, 
		accruedint, 
		nextcoupon,
		matdate,
		couponperiod,
		buybackprice, 
		buybackdate, 
		couponpercent, 
		offerdate,
		duration 
	FROM {{ ref('bonds') }}
),
securities AS (
	SELECT * FROM shares_data
	UNION ALL
	SELECT * FROM bonds_data
)
SELECT
	s.secid, 
	s.boardid, 
	s.board_title, 
	s.market_id, 
	s.sectype, 
	s.sectype_name, 
	s.sectype_group, 
	s.shortname, 
	s.secname, 
	s.latname, 
	s.lotsize, 
	s.decimals, 
	s.faceunit,
	s.currencyid, 
	s.issuesize, 
	s.prevprice_ AS prevprice, 
	s.prevdate_ AS prevdate, 
	(last-s.prevprice_) AS to_previous_cost,
	if(s.prevprice_>0, round((toFloat64(last-s.prevprice_)/toFloat64(s.prevprice_))*100, 2), 0) as to_previous_prc,
	s.open_ AS open, 
	s.low_ AS low, 
	s.high_ AS high, 
	if(s.last_>0, s.last_, s.prevprice_) AS last,
	s.bid_ AS bid, 
	s.offer_ AS offer, 
	s.spread_ AS spread, 
	s.biddeptht, 
	s.offerdeptht, 
	s.lastchange, 
	s.lastchangeprcnt, 
	s.qty, 
	s.value, 
	s.value_usd, 
	s.numtrades, 
	s.voltoday, 
	s.valtoday, 
	s.valtoday_usd, 
	s.valtoday_rur, 
	s.updatetime, 
	s.couponvalue, 
	s.accruedint, 
	s.nextcoupon, 
	s.matdate, 
	s.couponperiod, 
	s.buybackprice, 
	s.buybackdate, 
	s.couponpercent, 
	s.offerdate, 
	s.duration
FROM securities s
