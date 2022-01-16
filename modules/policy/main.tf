terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sample" {
  name     = "medium-blog"
  location = "West Europe"
}

resource "azurerm_policy_definition" "location_policy" {
  name         = "locRestrictPolicy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Location Restriction Policy"

  metadata = <<METADATA
    {
    "category": "General"
    }

METADATA


  policy_rule = <<POLICY_RULE
    {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "deny"
    }
  }
POLICY_RULE


  parameters = <<PARAMETERS
    {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS

}

resource "azurerm_resource_group_policy_assignment" "location_policy_assigment" {
  name                 = "locRestrictAssign"
  resource_group_id    = azurerm_resource_group.sample.id
  policy_definition_id = azurerm_policy_definition.location_policy.id
  parameters = <<PARAMETERS
  {
      "allowedLocations": {
      "value": ["southcentralus"]
    }
  }
  PARAMETERS
}

resource "azurerm_resource_group_policy_assignment" "sku_policy_assigment" {
  name                 = "skuRestrictAssign"
  resource_group_id    = azurerm_resource_group.sample.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"

  parameters = <<PARAMETERS
  {
      "listOfAllowedSKUs": {
      "value": ["Dsv3","Dv3"]
    }
  }
  PARAMETERS
}
