/*
 * mui_priv.h
 *
 * Copyright (C) 2023 Michel Pollet <buserror@gmail.com>
 *
 * SPDX-License-Identifier: MIT
 */

/*
 * This are functions that are used internally by the MUI library itself,
 * but are not part of the public API.
 */

#pragma once

#include "mui.h"

// private, used my mui_draw() -- do not use outside of this context
void
mui_window_draw(
		mui_window_t *win,
		mui_drawable_t *dr);
bool
mui_window_handle_mouse(
		mui_window_t *win,
		mui_event_t *event);
bool
mui_window_handle_keyboard(
		mui_window_t *win,
		mui_event_t *event);


void
mui_control_draw(
		mui_window_t * 	win,
		mui_control_t * c,
		mui_drawable_t *dr );

bool
mui_control_event(
		mui_control_t * c,
		mui_event_t * 	ev );


/* This is common to:
 *  - Menu titles in the menubar
 *  - Menu items in a popup menu
 *  - Menu items pointing to a sub-menu
 */
typedef struct mui_menuitem_control_t {
	mui_control_t 			control;
	mui_menu_item_t			item;
} mui_menuitem_control_t;

/* this is for menu title, popup menu labels, and hierarchical menu items */
typedef struct mui_menu_control_t {
	mui_menuitem_control_t 	item;
	mui_menu_items_t 		menu;
	c2_rect_t 				menu_frame;
	mui_window_t * 			menubar;
	mui_window_t *			menu_window;	// when open
} mui_menu_control_t;

void
mui_wdef_menubar_draw(
		struct mui_window_t * 	win,
		mui_drawable_t * 		dr);
void
mui_popuptitle_draw(
		mui_window_t * 	win,
		mui_control_t * c,
		mui_drawable_t *dr );
void
mui_menuitem_draw(
		mui_window_t * 	win,
		mui_control_t * c,
		mui_drawable_t *dr );
void
mui_menutitle_draw(
		mui_window_t * 	win,
		mui_control_t * c,
		mui_drawable_t *dr );

// return true if window win is the menubar
bool
mui_menubar_window(
		mui_window_t * win);
