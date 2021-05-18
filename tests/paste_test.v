module tests

import os

import billyateallcookies.pastemyst.endpoints
import billyateallcookies.pastemyst.types

/**
 * Sample pasty object for test purposes.
 */
const sample_pasty = types.Pasty{
	title: "Test Pasty",
	language: "plain text",
	code: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
}

/**
 * personal API token for authorization, value is taken from enviromental variable;
 * can be provided manually here.
 */
const api_token = os.getenv("API_TOKEN")

fn testsuite_begin () {
	if api_token == "" {
		println("No API token was supplied in the environment variables. " + "Unit tests that require authorization may not pass.")
	}
}

/**
 * retrieves public pastes
 */
fn test_get_public_paste () ? {
	mut paste := endpoints.get_paste(id: "99is6n23") ?
	assert paste.title == "public paste example title" 
}

/**
 * retrieves private paste
 */
fn test_get_private_paste () ? {
	mut paste := endpoints.get_paste(id: "grajzo1h", token: api_token) ?
	assert paste.title == "private paste example title" 
}

/**
 * create pastes
 */
fn test_create_public_paste () ? {
	mut title     := "[pastemyst.v] Public Paste Create Test"
	mut new_paste := types.Paste {
		title      : title,
		expires_in : "1h",
		pasties    : [sample_pasty]
	}

	mut created_paste := endpoints.create_paste(paste: new_paste) ?
	assert created_paste.title == title
}

/**
 * create private pastes
 */
fn test_create_private_paste () ? {
	mut title     := "[pastemyst.v] Private Paste Create Test"
	mut new_paste := types.Paste {
		title      : title,
		expires_in : "1h",
		is_private : true
		pasties    : [sample_pasty]
	}

	created_paste := endpoints.create_paste(paste: new_paste, token: api_token) ?
	assert created_paste.title == title
	assert created_paste.is_private == true

	remove_paste(created_paste.id) ?
}

/**
 * delete pastes
 */
fn test_delete_paste () ? {
	mut new_paste := types.Paste {
		is_private: true,
		pasties   : [sample_pasty]
	}
	mut created_paste := endpoints.create_paste(paste: new_paste, token: api_token) ?
	assert created_paste.title == "(Untitled)"

	mut is_paste_deleted := endpoints.delete_paste(id: created_paste.id, token: api_token) ?
	assert is_paste_deleted == true
}

/**
 * edit pastes
 */
fn test_edit_paste () ? {
	mut new_paste := types.Paste {
		is_private: true,
		pasties   : [sample_pasty]
	}
	mut created_paste := endpoints.create_paste(paste: new_paste, token: api_token) ?
	assert created_paste.title == "(Untitled)"

	mut desired_title := "[pastemyst.v] Paste Edit Test"
	mut desired_edit  := types.Edit {
		title: desired_title
	}
	mut edited_paste := endpoints.edit_paste(id: created_paste.id, edit: desired_edit, token: api_token) ?
	assert edited_paste.title == desired_title

	remove_paste(created_paste.id) ?
}

/**
 * Cleanup created pastes after tests.
 */
fn remove_paste(id string) ? {
	mut is_paste_deleted := endpoints.delete_paste(id: id, token: api_token) ?
	if mut is_paste_deleted {
		println("Paste deleted")
	} else {
		println("Couldn't delete paste $id")
	}
}


// UNSUPPORTED CLEANUP SYSTEM
// struct Client {
// mut:
//     created_pastes []types.Paste
// }

// fn (mut client Client) add_paste (paste types.Paste) {
//     client.created_pastes << paste
// }
// fn (mut client Client) get_all_created_pastes () ?[]string {
//     return client.created_pastes
// }

// const client = Client{}

// fn testsuite_end () ? {
// 	if created_pastes.len > 0 {
// 		println("==== Paste Cleanup ====")
// 		for created_paste in client.get_all_created_pastes {
// 			println("Cleaning up paste with id: $created_paste.id, title: $created_paste.title")
// 			mut is_paste_deleted := endpoints.delete_paste(id: created_paste.id, token: api_token) ?
// 			if is_paste_deleted {
// 				println("Paste deleted")
// 			} else {
// 				println("Couldn't delete paste $created_paste.id")
// 			}
// 		}
// 		println("=======================")
// 	}
// }