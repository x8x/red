Red/System [
	Title:	"DRAW Direct2D Backend"
	Author: "Xie Qingtian"
	File: 	%draw.reds
	Tabs: 	4
	Rights: "Copyright (C) 2016 Qingtian Xie. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

#include %text-box.reds

draw-state!: alias struct! [unused [integer!]]

draw-begin: func [
	ctx			[draw-ctx!]
	hWnd		[handle!]
	/local
		this	[this!]
		rt		[ID2D1HwndRenderTarget]
		_11		[integer!]
		_12		[integer!]
		_21		[integer!]
		_22		[integer!]
		_31		[integer!]
		_32		[integer!]
		m		[D2D_MATRIX_3X2_F]
		bg-clr	[integer!]
		brush	[integer!]
		target	[int-ptr!]
		brushes [int-ptr!]
][
	zero-memory as byte-ptr! ctx size? draw-ctx!
	ctx/pen-width:	as float32! 1.0
	ctx/pen?:		yes
	ctx/hwnd:		hWnd
	ctx/font-color:	-1

	target: get-hwnd-render-target hWnd
	this: as this! target/value
	ctx/dc: as handle! this
	ctx/brushes: target

	rt: as ID2D1HwndRenderTarget this/vtbl
	rt/SetTextAntialiasMode this 1				;-- ClearType

	rt/BeginDraw this
	_11: 0 _12: 0 _21: 0 _22: 0 _31: 0 _32: 0
	m: as D2D_MATRIX_3X2_F :_32
	m/_11: as float32! 1.0
	m/_22: as float32! 1.0
	rt/SetTransform this m						;-- set to identity matrix

	bg-clr: to-bgr as node! GetWindowLong hWnd wc-offset + 4 FACE_OBJ_COLOR
	if bg-clr <> -1 [							;-- paint background
		rt/Clear this to-dx-color bg-clr null
	]

	brush: select-brush target + 1 ctx/pen-color
	if zero? brush [
		rt/CreateSolidColorBrush this to-dx-color ctx/pen-color null null :brush
		put-brush target + 1 ctx/pen-color brush
	]
	ctx/pen: brush
]

release-d2d: func [
	ctx		[draw-ctx!]
	/local
		IUnk [IUnknown]
		this [this!]
][
	;;TBD release all brushes when D2DERR_RECREATE_TARGET or exit the process
]

draw-end: func [
	ctx		[draw-ctx!]
	hWnd	[handle!]
	/local
		this [this!]
		rt	 [ID2D1HwndRenderTarget]
		hr	 [integer!]
][
	this: as this! ctx/dc
	rt: as ID2D1HwndRenderTarget this/vtbl
	hr: rt/EndDraw this null null

	release-d2d ctx

	switch hr [
		COM_S_OK [ValidateRect hWnd null]
		D2DERR_RECREATE_TARGET [
			d2d-release-target ctx/brushes
			ctx/dc: null
			SetWindowLong hWnd wc-offset - 24 0
		]
		default [
			0		;@@ TBD log error!!!
		]
	]
]

OS-draw-pen: func [
	ctx		[draw-ctx!]
	color	[integer!]
	off?	[logic!]
	/local
		this	[this!]
		brush	[ID2D1SolidColorBrush]
][
	if any [ctx/pen-color <> color ctx/pen? = off?][
		ctx/pen?: not off?
		ctx/pen-color: color
		if ctx/pen? [
			this: as this! ctx/pen
			brush: as ID2D1SolidColorBrush this/vtbl
			brush/SetColor this to-dx-color color null
		]
	]
]

OS-draw-text: func [
	ctx		[draw-ctx!]
	pos		[red-pair!]
	text	[red-string!]
	catch?	[logic!]
	/local
		this	[this!]
		rt		[ID2D1HwndRenderTarget]
		IUnk	[IUnknown]
		values	[red-value!]
		str		[red-string!]
		size	[red-pair!]
		int		[red-integer!]
		state	[red-block!]
		styles	[red-block!]
		w		[integer!]
		h		[integer!]
		fmt		[this!]
		layout	[this!]
][
	this: as this! ctx/dc
	rt: as ID2D1HwndRenderTarget this/vtbl

	either TYPE_OF(text) = TYPE_OBJECT [				;-- text-box!
		values: object/get-values as red-object! text
		state: as red-block! values + TBOX_OBJ_STATE

		layout: either TYPE_OF(state) = TYPE_BLOCK [
			int: as red-integer! block/rs-head state
			as this! int/value
		][
			OS-text-box-layout as red-object! text ctx/brushes yes
		]
	][
		exit
	]

	txt-box-draw-background ctx/brushes pos layout
	rt/DrawTextLayout this as float32! pos/x as float32! pos/y layout ctx/pen 0
]


OS-draw-shape-beginpath: func [
	ctx			[draw-ctx!]
][

]

OS-draw-shape-endpath: func [
	ctx			[draw-ctx!]
	close?		[logic!]
	return:		[logic!]
][

]

OS-draw-shape-close: func [
	ctx		[draw-ctx!]
][

]

OS-draw-shape-moveto: func [
	ctx		[draw-ctx!]
	coord	[red-pair!]
	rel?	[logic!]
][

]

OS-draw-shape-line: func [
	ctx			[draw-ctx!]
	start		[red-pair!]
	end			[red-pair!]
	rel?		[logic!]
][

]

OS-draw-shape-axis: func [
	ctx			[draw-ctx!]
	start		[red-value!]
	end			[red-value!]
	rel?		[logic!]
	hline		[logic!]
][

]

OS-draw-shape-curve: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
	rel?	[logic!]
][

]

OS-draw-shape-qcurve: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
	rel?	[logic!]
][

]

OS-draw-shape-curv: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
	rel?	[logic!]
][

]

OS-draw-shape-qcurv: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
	rel?	[logic!]
][

]

OS-draw-shape-arc: func [
	ctx		[draw-ctx!]
	end		[red-pair!]
	sweep?	[logic!]
	large?	[logic!]
	rel?	[logic!]
][

]

OS-draw-anti-alias: func [
	ctx [draw-ctx!]
	on? [logic!]
][

]

OS-draw-line: func [
	ctx	   [draw-ctx!]
	point  [red-pair!]
	end	   [red-pair!]
][

]

OS-draw-fill-pen: func [
	ctx		[draw-ctx!]
	color	[integer!]									;-- 00bbggrr format
	off?	[logic!]
	alpha?	[logic!]
][

]

OS-draw-line-width: func [
	ctx			[draw-ctx!]
	width		[red-value!]
][

]

OS-draw-box: func [
	ctx			[draw-ctx!]
	upper		[red-pair!]
	lower		[red-pair!]
][

]

OS-draw-triangle: func [		;@@ TBD merge this function with OS-draw-polygon
	ctx		[draw-ctx!]
	start	[red-pair!]
][

]

OS-draw-polygon: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
][

]

OS-draw-spline: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
	closed? [logic!]
][

]

do-draw-ellipse: func [
	ctx		[draw-ctx!]
	x		[integer!]
	y		[integer!]
	width	[integer!]
	height	[integer!]
][

]

OS-draw-circle: func [
	ctx	   [draw-ctx!]
	center [red-pair!]
	radius [red-integer!]
	/local
		this	[this!]
		rt		[ID2D1HwndRenderTarget]
		ellipse [D2D1_ELLIPSE]
][
	this: as this! ctx/dc
	rt: as ID2D1HwndRenderTarget this/vtbl

	ellipse: declare D2D1_ELLIPSE
	ellipse/x: as float32! center/x
	ellipse/y: as float32! center/y
	ellipse/radiusX: get-float32 radius
	ellipse/radiusY: ellipse/radiusX
	if ctx/brush? [
		rt/FillEllipse this ellipse ctx/brush
	]
	if ctx/pen? [
		rt/DrawEllipse this ellipse ctx/pen ctx/pen-width ctx/pen-style
	]
]

OS-draw-ellipse: func [
	ctx		 [draw-ctx!]
	upper	 [red-pair!]
	diameter [red-pair!]
][

]

OS-draw-font: func [
	ctx		[draw-ctx!]
	font	[red-object!]
][

]

OS-draw-arc: func [
	ctx	   [draw-ctx!]
	center [red-pair!]
	end	   [red-value!]
][

]

OS-draw-curve: func [
	ctx		[draw-ctx!]
	start	[red-pair!]
	end		[red-pair!]
][

]

OS-draw-line-join: func [
	ctx		[draw-ctx!]
	style	[integer!]
][

]

OS-draw-line-cap: func [
	ctx		[draw-ctx!]
	style	[integer!]
][

]

OS-draw-image: func [
	ctx			[draw-ctx!]
	image		[red-image!]
	start		[red-pair!]
	end			[red-pair!]
	key-color	[red-tuple!]
	border?		[logic!]
	crop1		[red-pair!]
	pattern		[red-word!]
][

]


OS-draw-brush-bitmap: func [
	ctx		[draw-ctx!]
	img		[red-image!]
	crop-1	[red-pair!]
	crop-2	[red-pair!]
	mode	[red-word!]
	brush?	[logic!]
][

]

OS-draw-brush-pattern: func [
	ctx		[draw-ctx!]
	size	[red-pair!]
	crop-1	[red-pair!]
	crop-2	[red-pair!]
	mode	[red-word!]
	block	[red-block!]
	brush?	[logic!]
][

]


OS-draw-grad-pen-old: func [
	ctx			[draw-ctx!]
	type		[integer!]
	mode		[integer!]
	offset		[red-pair!]
	count		[integer!]					;-- number of the colors
	brush?		[logic!]
][

]

OS-draw-grad-pen: func [
	ctx			[draw-ctx!]
	mode		[integer!]
	stops		[red-value!]
	count		[integer!]
	skip-pos	[logic!]
	positions	[red-value!]
	focal?		[logic!]
	spread		[integer!]
	brush?		[logic!]
][

]

OS-set-clip: func [
	ctx		[draw-ctx!]
	u		[red-pair!]
	l		[red-pair!]
	rect?	[logic!]
	mode	[integer!]
][

]

OS-matrix-rotate: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]
	angle		[red-integer!]
	center		[red-pair!]
][

]

OS-matrix-scale: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]
	sx			[red-integer!]
	sy			[red-integer!]
][

]

OS-matrix-translate: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]
	x			[integer!]
	y			[integer!]
][

]

OS-matrix-skew: func [
	ctx		    [draw-ctx!]
	pen-fill    [integer!]
	sx			[red-integer!]
	sy			[red-integer!]
][

]

OS-matrix-transform: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]
	center		[red-pair!]
	scale		[red-integer!]
	translate	[red-pair!]
][
	
]

OS-matrix-push: func [ctx [draw-ctx!] state [draw-state!]][

]

OS-matrix-pop: func [ctx [draw-ctx!] state [draw-state!]][]

OS-matrix-reset: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]
][
	
]

OS-matrix-invert: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]

][

]

OS-matrix-set: func [
	ctx			[draw-ctx!]
	pen-fill	[integer!]
	blk			[red-block!]
][
	
]

OS-set-matrix-order: func [
	ctx		[draw-ctx!]
	order	[integer!]
][

]
