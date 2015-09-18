# -*- coding: utf-8 -*-
#
# Copyright (c) 2015, Alcatel-Lucent Inc
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the copyright holder nor the names of its contributors
#       may be used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

{% for api in model.children_apis %}
from ..fetchers import {{sdk_class_prefix}}{{ api.plural_name }}Fetcher{% endfor %}
from bambou import NURESTObject{% if model.has_time_attribute %}
from time import time{% endif %}


class {{sdk_class_prefix}}{{ model.name }}(NURESTObject):
    """ Represents a {{ model.name }} in the {{product_accronym}}

        Notes:
            {{ model.description }}

        Warning:
            This file has been autogenerated. You should never change it.
            Override {{sdk_name}}.{{sdk_class_prefix}}{{model.name}} instead.
    """

    __rest_name__ = u"{{ model.remote_name }}"
    __resource_name__ = u"{{model.resource_name}}"

    def __init__(self, **kwargs):
        """ Initializes a {{ model.name }} instance

            Notes:
                You can specify all parameters while calling this methods.
                A special argument named `data` will enable you to load the
                object from a Python dictionary

            Examples:
                >>> {{ model.name.lower() }} = {{sdk_class_prefix}}{{ model.name }}(id=u'xxxx-xxx-xxx-xxx', name=u'{{ model.name }}')
                >>> {{ model.name.lower() }} = {{sdk_class_prefix}}{{ model.name }}(data=my_dict)
        """

        super({{sdk_class_prefix}}{{ model.name }}, self).__init__()

        # Read/Write Attributes
        {% for attribute in model.attributes %}
        self._{{ attribute.local_name|lower }} = None{% endfor %}
        {% for attribute in model.attributes %}
        self.expose_attribute(local_name=u"{{ attribute.local_name|lower }}", remote_name=u"{{ attribute.remote_name }}", attribute_type={{ attribute.local_type }}, is_required={{ attribute.required }}, is_unique={{ attribute.unique }}{% if attribute.allowed_choices and attribute.allowed_choices|length > 0  %}, choices={{ attribute.allowed_choices|sort|trim }}{% endif %}){% endfor %}
        {% if model.children_apis|length > 0 %}
        # Fetchers
        {% for api in model.children_apis %}
        self.{{ api.instance_plural_name }} = {{sdk_class_prefix}}{{ api.plural_name }}Fetcher.fetcher_with_object(parent_object=self)
        {% endfor %}{% endif %}
        {% if version > 3.1 and not model.remote_name.startswith('metadata') %}
        self.metadata = {{sdk_class_prefix}}MetadatasFetcher.fetcher_with_object(parent_object=self)
        {% endif %}

        self._compute_args(**kwargs)

    # Properties
    {% for attribute in model.attributes %}
    def _get_{{ attribute.local_name }}(self):
        """ Get {{ attribute.local_name }} value.

            Notes:
                {{ attribute.description }}

                {% if attribute.local_name != attribute.remote_name %}
                This attribute is named `{{ attribute.remote_name }}` in {{product_accronym}} API.
                {% endif %}
        """
        return self._{{ attribute.local_name }}

    def _set_{{ attribute.local_name }}(self, value):
        """ Set {{ attribute.local_name }} value.

            Notes:
                {{ attribute.description }}

                {% if attribute.local_name != attribute.remote_name %}
                This attribute is named `{{ attribute.remote_name }}` in {{product_accronym}} API.
                {% endif %}
        """
        self._{{ attribute.local_name }} = value

    {{ attribute.local_name }} = property(_get_{{ attribute.local_name }}, _set_{{ attribute.local_name }})
    {% endfor %}

