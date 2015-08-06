
let rec get_next_n_ite = (fun ( n ) ( t ) ( negs ) ( f ) -> (match ((n <= 0)) with
| true -> begin
(let _70_21223 = (f Microsoft_FStar_ToSMT_Term.mkTrue)
in (true, _70_21223, negs, t))
end
| false -> begin
(match (t.Microsoft_FStar_ToSMT_Term.tm) with
| Microsoft_FStar_ToSMT_Term.App ((Microsoft_FStar_ToSMT_Term.ITE, g::t::e::_51_7)) -> begin
(let _70_21228 = (let _70_21225 = (let _70_21224 = (Microsoft_FStar_ToSMT_Term.mkNot g)
in (negs, _70_21224))
in (Microsoft_FStar_ToSMT_Term.mkAnd _70_21225))
in (get_next_n_ite (n - 1) e _70_21228 (fun ( x ) -> (let _70_21227 = (Microsoft_FStar_ToSMT_Term.mkITE (g, t, x))
in (f _70_21227)))))
end
| Microsoft_FStar_ToSMT_Term.FreeV (_51_18) -> begin
(let _70_21229 = (f Microsoft_FStar_ToSMT_Term.mkTrue)
in (true, _70_21229, negs, t))
end
| _51_21 -> begin
(false, Microsoft_FStar_ToSMT_Term.mkFalse, Microsoft_FStar_ToSMT_Term.mkFalse, Microsoft_FStar_ToSMT_Term.mkFalse)
end)
end))

let rec is_ite_all_the_way = (fun ( n ) ( t ) ( negs ) ( l ) -> (match ((n <= 0)) with
| true -> begin
(raise (Support.Microsoft.FStar.Util.Impos))
end
| false -> begin
(match (t.Microsoft_FStar_ToSMT_Term.tm) with
| Microsoft_FStar_ToSMT_Term.FreeV (_51_27) -> begin
(let _70_21240 = (let _70_21239 = (let _70_21238 = (Microsoft_FStar_ToSMT_Term.mkNot t)
in (negs, _70_21238))
in (Microsoft_FStar_ToSMT_Term.mkAnd _70_21239))
in (true, l, _70_21240))
end
| _51_30 -> begin
(let _51_36 = (get_next_n_ite n t negs (fun ( x ) -> x))
in (match (_51_36) with
| (b, t, negs', rest) -> begin
(match (b) with
| true -> begin
(let _70_21243 = (let _70_21242 = (Microsoft_FStar_ToSMT_Term.mkImp (negs, t))
in (_70_21242)::l)
in (is_ite_all_the_way n rest negs' _70_21243))
end
| false -> begin
(false, [], Microsoft_FStar_ToSMT_Term.mkFalse)
end)
end))
end)
end))

let rec parse_query_for_split_cases = (fun ( n ) ( t ) ( f ) -> (match (t.Microsoft_FStar_ToSMT_Term.tm) with
| Microsoft_FStar_ToSMT_Term.Quant ((Microsoft_FStar_ToSMT_Term.Forall, l, opt, l', t)) -> begin
(parse_query_for_split_cases n t (fun ( x ) -> (let _70_21270 = (Microsoft_FStar_ToSMT_Term.mkForall'' (l, opt, l', x))
in (f _70_21270))))
end
| Microsoft_FStar_ToSMT_Term.App ((Microsoft_FStar_ToSMT_Term.Imp, t1::t2::_51_50)) -> begin
(let r = (match (t2.Microsoft_FStar_ToSMT_Term.tm) with
| Microsoft_FStar_ToSMT_Term.Quant ((Microsoft_FStar_ToSMT_Term.Forall, _51_59, _51_61, _51_63, _51_65)) -> begin
(parse_query_for_split_cases n t2 (fun ( x ) -> (let _70_21278 = (Microsoft_FStar_ToSMT_Term.mkImp (t1, x))
in (f _70_21278))))
end
| Microsoft_FStar_ToSMT_Term.App ((Microsoft_FStar_ToSMT_Term.ITE, _51_71)) -> begin
(let _51_77 = (is_ite_all_the_way n t2 Microsoft_FStar_ToSMT_Term.mkTrue [])
in (match (_51_77) with
| (b, l, negs) -> begin
(b, ((fun ( x ) -> (let _70_21287 = (Microsoft_FStar_ToSMT_Term.mkImp (t1, x))
in (f _70_21287))), l, negs))
end))
end
| _51_80 -> begin
(false, ((fun ( _51_81 ) -> Microsoft_FStar_ToSMT_Term.mkFalse), [], Microsoft_FStar_ToSMT_Term.mkFalse))
end)
in r)
end
| Microsoft_FStar_ToSMT_Term.App ((Microsoft_FStar_ToSMT_Term.ITE, _51_86)) -> begin
(let _51_92 = (is_ite_all_the_way n t Microsoft_FStar_ToSMT_Term.mkTrue [])
in (match (_51_92) with
| (b, l, negs) -> begin
(b, (f, l, negs))
end))
end
| _51_94 -> begin
(false, ((fun ( _51_95 ) -> Microsoft_FStar_ToSMT_Term.mkFalse), [], Microsoft_FStar_ToSMT_Term.mkFalse))
end))

let strip_not = (fun ( t ) -> (match (t.Microsoft_FStar_ToSMT_Term.tm) with
| Microsoft_FStar_ToSMT_Term.App ((Microsoft_FStar_ToSMT_Term.Not, hd::_51_100)) -> begin
hd
end
| _51_106 -> begin
t
end))

let rec check_split_cases = (fun ( f ) ( l ) ( check ) -> (Support.List.iter (fun ( t ) -> (let _70_21326 = (let _70_21325 = (let _70_21324 = (let _70_21323 = (f t)
in (Microsoft_FStar_ToSMT_Term.mkNot _70_21323))
in (_70_21324, None))
in Microsoft_FStar_ToSMT_Term.Assume (_70_21325))
in (check _70_21326))) (Support.List.rev l)))

let check_exhaustiveness = (fun ( f ) ( negs ) ( check ) -> (let _70_21347 = (let _70_21346 = (let _70_21345 = (let _70_21344 = (let _70_21343 = (Microsoft_FStar_ToSMT_Term.mkNot negs)
in (f _70_21343))
in (Microsoft_FStar_ToSMT_Term.mkNot _70_21344))
in (_70_21345, None))
in Microsoft_FStar_ToSMT_Term.Assume (_70_21346))
in (check _70_21347)))

let can_handle_query = (fun ( n ) ( q ) -> (match (q) with
| Microsoft_FStar_ToSMT_Term.Assume ((q', _51_118)) -> begin
(parse_query_for_split_cases n (strip_not q') (fun ( x ) -> x))
end
| _51_123 -> begin
(false, ((fun ( x ) -> x), [], Microsoft_FStar_ToSMT_Term.mkFalse))
end))

let handle_query = (fun ( _51_128 ) ( check ) -> (match (_51_128) with
| (f, l, negs) -> begin
(let l = (check_split_cases f l check)
in (check_exhaustiveness f negs check))
end))




