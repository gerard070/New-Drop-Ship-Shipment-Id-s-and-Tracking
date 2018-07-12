SELECT   v.NAME AS vendor_name_, 
         sk.sku AS sku_, 
         sk.sze 
                  ||' ' 
                  ||sk.color AS description_, 
         osk.quantity        AS qty_, 
         sh.shipment_id      AS shipment_, 
         o.order_id 
                  ||'-' 
                  || sh.shipment_number      AS order_, 
         To_char(o.date_created, 'MM/DD/YY') AS date_created_, 
         CASE 
                  WHEN os.vendor_confirmed_order = 1 THEN To_char(os.vendor_confirmed_order_date, 'MM/DD/YY')
                  ELSE 'Not_Confirmed' 
         END                                                  AS vendor_confirmed_order_date_, 
         To_char(os.tracknum_received_admin_date, 'MM/DD/YY')    tracknum_received_admin_date_, 
         sh.tracking_num                                      AS tracking_num_, 
         CASE sh.tracking_num_source_id 
                  WHEN 2 THEN 'Updated by UPS Application' 
                  ELSE '' 
         END                                            AS tracknum_source_, 
         sh.tracknum_autoadded_datetime                 AS tracking_autoadded_datetime_, 
         To_char(os.expected_delivery_date, 'MM/DD/YY') AS expected_ship_by_date_, 
         sk.production_days                             AS production_days_, 
         sm.descr                                       AS ship_method_, 
         o.email                                        AS email_, 
         sk.price                                       AS item_price_, 
         CASE 
                  WHEN vs.discount_percent IS NULL THEN vs.price_per_unit - ( 
                           CASE 
                                    WHEN vs.discount_fixed IS NULL THEN 0 
                                    ELSE vs.discount_fixed 
                           END) 
                  WHEN vs.discount_percent = 0 THEN vs.price_per_unit - ( 
                           CASE 
                                    WHEN vs.discount_fixed IS NULL THEN 0 
                                    ELSE vs.discount_fixed 
                           END) 
                  ELSE vs.price_per_unit * (1 - (vs.discount_percent / 100)) 
         END           AS discounted_, 
         a.postal_code AS postal_code_, 
         st.state_code AS state_code_, 
         dscat.type    AS drop_ship_category 
FROM     orders O, 
         order_shipment OS, 
         order_sku OSK, 
         sku SK, 
         ds_category DSCAT, 
         shipment SH, 
         vendor V, 
         vendor_sku VS, 
         ship_method SM, 
         address A, 
         state ST 
WHERE    o.order_id = sh.order_id 
AND      sh.shipment_id = os.shipment_id 
AND      os.order_sku_id = osk.order_sku_id 
AND      osk.sku = vs.sku 
AND      vs.sku = sk.sku 
AND      vs.vendor_id = v.id 
AND      sh.ship_method_id = sm.ship_method_id 
AND      sk.is_drop_ship = 1 
AND      sh.is_drop_ship = 1 
AND      sh.is_cancelled = 0 
AND      o.is_cancelled = 0 
AND      sh.address_id = a.address_id 
AND      a.state_id = st.state_id 
AND      sk.ds_category_id = dscat.id 
AND      sh.authorized > Date_trunc('day', {StartDate}) 
AND      o.date_created >= Date_trunc('day', {StartDate}) 
AND      o.date_created < Date_trunc('day', {EndDate}) + interval '1 day' 
AND      sh.is_cancelled = o.is_cancelled 
ORDER BY v.NAME, 
         to_char(o.date_created, 'MM/DD/YY');