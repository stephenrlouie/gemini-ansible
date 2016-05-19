import re

def regex_escape(string):
    '''Escape all regular expressions special characters from STRING.'''
    return re.escape(string)

class FilterModule(object):
    '''Backported Ansible 2 filters for Ansible 1.9.x'''

    def filters(self):
        return {
            'regex_escape': regex_escape,
        }
