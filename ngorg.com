// Bangla news: http://www.ngorg.com

function print_products($A) {
 $items = $A->Items;
 $aitems = (array) $items;
 $products = array();
 $items_sub = $aitems['Item'];
   if (is_array($items_sub) and $items_sub[0]) {
      foreach ($items_sub as $i => $E) {
         $products[] = print_product($E);
      }
   }
   else {
      print_product($D);
   }
   return $products;
}

function print_product($E) {
	if ($E){
		$url = 'null';	
		$url = $E->DetailPageURL;
		
		$miurl = $miwid = $mihig = 'null';
		if ($m = $E->MediumImage) {
			$miurl = $m->URL;
			$miwid = $m->Width;
			$mihig = $m->Height;
		}
		$liurl = $liwid = $lihig = 'null';
		if ($l = $E->LargeImage) {
			$liurl = $l->URL;
			$liwid = $l->Width;
			$lihig = $l->Height;
		}
		$title = 'null';
		if ($title = $E->ItemAttributes->Title) {
		}
		$author = 'null';
		if (is_array($author = $E->ItemAttributes->Author)) {
			foreach ($author as $i => $d) {
				if ($i);
			}
		}
		else{
			if ($d = $author) {
			}
		}
	
		$newPrice = 'null';
		$newPrice = $E->OfferSummary->LowestNewPrice->FormattedPrice;
		$usedPrice = 'null';
		$usedPrice = $E->OfferSummary->LowestUsedPrice->FormattedPrice;
	}
	return	array(
		'ItemUrl' 	=> $url,
		'Title' 	=> $title,	
		'newPrice' 	=> $newPrice,
		'usedPrice' => $usedPrice,
		'MidImg' 	=>  array(
						'miurl' => $miurl,
						'miwid' => $miwid,
						'mihig' => $mihig
						),
		'LarImg' 	=> array(
						'liurl' => $liurl,
						'liwid' => $liwid,
						'lihig' => $lihig
						),
		);
}

function aws_signed_request($region, $params, $public_key, $private_key){
    $method = "GET";
    $host = "ecs.amazonaws.".$region;
    $uri = "/onca/xml";
    $params["Service"] = "AWSECommerceService";
    $params["AWSAccessKeyId"] = $public_key;
    $params["Timestamp"] = gmdate("Y-m-d\TH:i:s\Z",time());  //may not be more than 15 minutes out of date!
    $params["Version"] = "2009-03-31";
    ksort($params);
    $canonicalized_query = array();
    foreach ($params as $param=>$value){
        $param = str_replace("%7E", "~", rawurlencode($param));
        $value = str_replace("%7E", "~", rawurlencode($value));
        $canonicalized_query[] = $param."=".$value;
    }
    $canonicalized_query = implode("&", $canonicalized_query);
    $string_to_sign = $method."\n".$host."\n".$uri."\n".$canonicalized_query;
    $signature = base64_encode(hash_hmac("sha256", $string_to_sign, $private_key, True));
    $signature = rawurlencode($signature);

    $request = "http://".$host.$uri."?".$canonicalized_query."&Signature=".$signature; 
    return $request;
}

 
$Aassociates_id = array(
		'de' => 'chipdir00', 
		'fr' => 'chipdir010', 
		'jp' => 'INVALID', 
		'uk' => 'chipdir03', 
		'us' => 'chipdir'
		);
$Aserver = array(
		'de' => array(
				'ext' => 'de'                      ,  //German normal server
				'nor' => 'http://www.amazon.de'    ,  //German normal server
				'xml' => 'http://xml-eu.amazon.com',  //German xml server
				),
		'fr' => array(
				'ext' => 'fr'                      ,  //French normal server
				'nor' => 'http://www.amazon.fr'    ,  //French normal server
				'xml' => 'http://xml-eu.amazon.com',  //French xml server
				),
		'jp' => array(
				'ext' => 'jp'                      ,  //Japanese normal server, not co.jp!
				'nor' => 'http://www.amazon.co.jp' ,  //Japanese normal server
				'xml' => 'http://xml.amazon.com'   ,  //Japanese xml server
				),
		'uk' => array(
				'ext' => 'co.uk'                   ,  //UK normal server
				'nor' => 'http://www.amazon.co.uk' ,  //UK normal server
				'xml' => 'http://xml-eu.amazon.com',  //UK xml server
				),
		'us' => array(
				'ext' => 'com'                     ,  //USA normal server
				'nor' => 'http://www.amazon.com'   ,  //USA normal server
				'xml' => 'http://xml.amazon.com'   ,  //USA xml server
				)
	);
