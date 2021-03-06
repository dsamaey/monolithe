{{ header }}

package {{ package_name }};

import net.nuagenetworks.bambou.{{ superclass_name }};
import net.nuagenetworks.bambou.annotation.RestEntity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
{% if specification.attributes|length > 0 -%} 
import com.fasterxml.jackson.annotation.JsonProperty;
{% endif -%}
import com.fasterxml.jackson.annotation.JsonIgnore;

{% if specification.child_apis|length > 0 -%}   
{% for api in specification.child_apis -%}
{% set child_spec = specification_set[api.rest_name] %}
import {{ package_name }}.fetchers.{{ class_prefix }}{{ child_spec.entity_name_plural }}Fetcher;
{%- endfor %}
{%- endif %}

@JsonIgnoreProperties(ignoreUnknown = true)
@RestEntity(restName = "{{ specification.rest_name }}", resourceName = "{{ specification.resource_name }}")
public class {{ class_prefix }}{{ specification.entity_name }} extends {{ superclass_name }} {

   private static final long serialVersionUID = 1L;

   {% for attribute in specification.attributes -%}
   {% if attribute.type == "enum" or attribute.subtype == "enum" %}
   {%- set field_name = attribute.local_name[0:1].upper() + attribute.local_name[1:] %}
   public enum {{ field_name }} { {% for choice in attribute.allowed_choices %}{{ choice }}{% if not loop.last %}, {% endif %}{% endfor %} };
   {%- endif %}
   {%- endfor %}

   {% for attribute in specification.attributes %}
   @JsonProperty(value = "{{ attribute.name }}")
   protected {{ attribute.local_type }} {{ attribute.local_name }};
   {% endfor %}

   {% if specification.child_apis|length > 0 -%}
   {% for api in specification.child_apis %}
   {%- set child_spec = specification_set[api.rest_name] %}
   @JsonIgnore
   private {{ class_prefix }}{{ child_spec.instance_name_plural }}Fetcher {{ child_spec.instance_name_plural[0:1].lower() + child_spec.instance_name_plural[1:] }};
   {% endfor %}
   {%- endif %}

{%- set add_warning = {} %}
{%- for attribute, value in attribute_defaults.iteritems() %}{% if value.startswith(attribute + '.') %}{% set _ = add_warning.update({'enabled' : True}) %}{% endif %}{% endfor %}
{% if add_warning %}   @SuppressWarnings("static-access"){% endif %}
   public {{ class_prefix }}{{ specification.entity_name }}() {
      {% for attribute, value in attribute_defaults.iteritems() -%}
      {{attribute}} = {{value}};
      {% endfor -%}

      {% if specification.child_apis|length > 0 -%}   
      {% for api in specification.child_apis %}
      {%- set child_spec = specification_set[api.rest_name] %}
      {{ child_spec.instance_name_plural[0:1].lower() + child_spec.instance_name_plural[1:] }} = new {{ class_prefix }}{{ child_spec.entity_name_plural }}Fetcher(this);
      {% endfor %}
      {%- endif %}
   }

   {% for attribute in specification.attributes %}
   {%- set field_name = attribute.local_name[0:1].upper() + attribute.local_name[1:] -%}
   @JsonIgnore
   public {% if attribute.local_type == "enum" %}{{ field_name }}{% else %}{{ attribute.local_type }}{% endif %} get{{ field_name }}() {
      return {{ attribute.local_name }};
   }

   @JsonIgnore
   public void set{{ field_name }}({% if attribute.local_type == "enum" %}{{ field_name }}{% else %}{{ attribute.local_type }}{% endif %} value) { 
      this.{{ attribute.local_name }} = value;
   }
   {% endfor %}

   {% if specification.child_apis|length > 0 -%}
   {% for api in specification.child_apis %}
   {%- set child_spec = specification_set[api.rest_name] %}
   @JsonIgnore
   public {{ class_prefix }}{{ child_spec.instance_name_plural }}Fetcher get{{ child_spec.entity_name_plural }}() {
      return {{ child_spec.entity_name_plural[0:1].lower() + child_spec.entity_name_plural[1:] }};
   }
   {% endfor %}
   {%- endif %}

   public String toString() {
      return "{{ class_prefix }}{{ specification.entity_name }} ["{% for attribute in specification.attributes %} + "{% if not loop.first %}, {% endif %}{{ attribute.local_name }}=" + {{ attribute.local_name }}{% endfor %} + ", id=" + id + ", parentId=" + parentId + ", parentType=" + parentType + ", creationDate=" + creationDate + ", lastUpdatedDate="
              + lastUpdatedDate + ", owner=" + owner {% if superclass_name == "RestRootObject" %} + ", apiKey=" + apiKey {% endif %} + "]";
   }
   
   {% if override_content -%}
   {{ override_content.replace('\n', '\n   ') }}
   {%- endif %}
}
