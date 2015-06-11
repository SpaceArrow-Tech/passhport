# -*-coding:Utf-8 -*-

"""Contains functions which make requests to the server for user management"""

import requests

url_passhport = "http://127.0.0.1:5000/"

def requests_user_list():
    """Get the list of all users"""

    url_list = url_passhport + "user/list"

    try:
        r = requests.get(url_list)
    except requests.RequestException, e:
        print("ERROR: " + str(e.message))
    else:
        if r.text == "":
            print("No user in database.\n")
        else:
            print(r.text)

        if r.status_code == requests.codes.ok:
            return 0

    return 1

def requests_user_search(pattern):
    """Get the list of users following the pattern"""

    url_search = url_passhport + "user/search/" + pattern

    try:
        r = requests.get(url_search)
    except requests.RequestException, e:
        print("ERROR: " + str(e.message))
    else:
        if r.text == "":
            print("No user found with this pattern.\n")
        else:
            print(r.text)

        if r.status_code == requests.codes.ok:
            return 0

    return 1

def requests_user_create(email, comment, sshkey):
    """User creation on passhportd via API"""

    user_data = {'email': email, 'comment': comment, 'sshkey': sshkey}
    url_create = url_passhport + "user/create"

    try:
        r = requests.post(url_create, data = user_data)
    except requests.RequestException, e:
        print("ERROR: " + str(e.message))
    else:
        print(r.text)

        if r.status_code == requests.codes.ok:
            return 0

    return 1

def requests_user_show(email):
    """Get data about a user"""

    url_show = url_passhport + "user/show/" + email

    try:
        r = requests.get(url_show)
    except requests.RequestException, e:
        print("ERROR: " + str(e.message))
    else:
        print(r.text)

        if r.status_code == requests.codes.ok:
            return 0
# -*-coding:Utf-8 -*-

    return 1

def requests_user_edit(email, new_email, new_comment, new_sshkey):
    """User modification on passhportd via API"""

    user_data = {'email': email, 'new_email': new_email, 'new_comment': new_comment, 'new_sshkey': new_sshkey}
    url_edit = url_passhport + "user/edit"

    try:
        r = requests.post(url_edit, data = user_data)
    except requests.RequestException, e:
        print("ERROR: " + str(e.message))
    else:
        print(r.text)

        if r.status_code == requests.codes.ok:
            return 0

    return 1
