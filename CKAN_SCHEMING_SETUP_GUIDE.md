# CKAN Scheming Extension - Installation and Configuration Guide

This guide walks you through installing and configuring the [ckanext-scheming](https://github.com/ckan/ckanext-scheming) extension for CKAN in a Docker environment, specifically for the ckan-docker project.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Creating a Custom Schema](#creating-a-custom-schema)
6. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
7. [Verification](#verification)
8. [Example Schema](#example-schema)
9. [Additional Resources](#additional-resources)

---

## Overview

### What is ckanext-scheming?

`ckanext-scheming` is a CKAN extension that allows you to configure and customize CKAN schemas using JSON files instead of writing Python code. This makes it easier to:

- Add custom fields to datasets, organizations, and groups
- Define field types, validation rules, and display properties
- Create dropdown menus, date pickers, and other input types
- Customize the dataset creation form without touching CKAN's core code

### Why Use Scheming?

- **No Python Required**: Define schemas in simple JSON files
- **Easy Customization**: Add domain-specific fields to your datasets
- **Validation**: Built-in validators for different field types
- **Flexible**: Supports multiple dataset types with different schemas

---

## Prerequisites

Before you begin, ensure you have:

- Docker and docker-compose installed
- Basic understanding of CKAN concepts (datasets, resources, organizations)
- A working ckan-docker installation
- Text editor for editing JSON and configuration files

---

## Installation

### Step 1: Add Extension to Dockerfile

Edit your [ckan/Dockerfile.dev](ckan/Dockerfile.dev) file and add the ckanext-scheming installation line:

```dockerfile
### Scheming ###
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'
```

**Note**: This installs the extension directly from the GitHub repository. You can specify a specific version/tag by changing `@master` to `@v3.0.0` (or your desired version).

### Step 2: Rebuild the Docker Image

After modifying the Dockerfile, rebuild your CKAN container:

```bash
docker-compose -f docker-compose.dev.yml build ckan-dev
```

---

## Configuration

### Step 3: Enable the Plugin

You need to enable the scheming plugin in two places:

#### A. In [.env](.env) file:

Add `scheming_datasets` to your `CKAN__PLUGINS` variable:

```bash
CKAN__PLUGINS="image_view text_view datatables_view datastore datapusher envvars scheming_datasets"
```

#### B. In [docker-compose.dev.yml](docker-compose.dev.yml):

Update the `ckan-dev` service environment section:

```yaml
environment:
  CKAN__PLUGINS: "image_view text_view datatables_view datastore datapusher envvars scheming_datasets"
```

### Step 4: Configure Schema Path

You need to tell CKAN where to find your custom schema file.

#### A. Create Schema Directory Mount

In [docker-compose.dev.yml](docker-compose.dev.yml), add a volume mount under the `ckan-dev` service:

```yaml
volumes:
  - ckan_storage:/var/lib/ckan
  - ./src:/srv/app/src_extensions
  # ... other volumes ...
  - ./stockton_schema.json:/srv/app/schemas/stockton_schema.json
```

#### B. Set Schema Path Environment Variable

**IMPORTANT**: The path must use the `file://` prefix for absolute paths.

In [.env](.env) file:

```bash
CKAN__SCHEMING__DATASET_SCHEMAS="file:///srv/app/schemas/stockton_schema.json"
```

In [docker-compose.dev.yml](docker-compose.dev.yml):

```yaml
environment:
  CKAN__PLUGINS: "image_view text_view datatables_view datastore datapusher envvars scheming_datasets"
  CKAN__SCHEMING__DATASET_SCHEMAS: "file:///srv/app/schemas/stockton_schema.json"
```

**Note**: The path `/srv/app/schemas/stockton_schema.json` is the path **inside the container**, not on your host machine.

### Step 5: Start the Container

Restart your CKAN container to apply the changes:

```bash
docker-compose -f docker-compose.dev.yml restart ckan-dev
```

Or start from scratch:

```bash
docker-compose -f docker-compose.dev.yml up -d
```

---

## Creating a Custom Schema

### Schema File Structure

Create a JSON file (e.g., `stockton_schema.json`) in your project root with this basic structure:

```json
{
  "scheming_version": 1,
  "dataset_type": "dataset",
  "about": "Your Custom Schema Name",
  "about_url": "http://github.com/ckan/ckanext-scheming",
  "dataset_fields": [
    // Dataset fields go here
  ],
  "resource_fields": [
    // Resource fields go here
  ]
}
```

### Available Presets

Scheming provides built-in presets for common field types. Here are the most useful ones:

#### Dataset Field Presets

- `title` - Large text input with slug preview
- `dataset_slug` - Auto-generated URL-friendly name
- `markdown` - Markdown editor and display
- `date` - Date picker
- `datetime` - Date and time picker
- `datetime_tz` - Date, time, and timezone picker
- `select` - Dropdown menu (requires `choices` array)
- `multiple_select` - Multi-select dropdown
- `multiple_checkbox` - Checkbox group
- `tag_string_autocomplete` - Tag input with autocomplete
- `dataset_organization` - Organization selector
- `json_object` - JSON field editor

#### Resource Field Presets

- `resource_url_upload` - File upload or URL input
- `resource_format_autocomplete` - Format selector with autocomplete

### Field Definition Examples

#### Text Field

```json
{
  "field_name": "impact_factor",
  "label": "Impact Factor",
  "form_snippet": "text.html",
  "display_snippet": "text.html",
  "form_placeholder": "e.g. 20.5"
}
```

#### Date Field

```json
{
  "field_name": "date_founded",
  "label": "Date Founded",
  "preset": "date",
  "help_text": "The year the dataset was established."
}
```

#### Dropdown/Select Field

```json
{
  "field_name": "domain_name",
  "label": "Content Domain",
  "preset": "select",
  "choices": [
    { "value": "mental_health", "label": "Mental Health" },
    { "value": "cognitive_training", "label": "Cognitive Training" },
    { "value": "financial_knowledge", "label": "Financial Knowledge" }
  ]
}
```

#### Markdown Field

```json
{
  "field_name": "notes",
  "label": "Short Description",
  "form_placeholder": "A brief summary...",
  "preset": "markdown"
}
```

### Required Standard Fields

Your schema should always include these standard CKAN fields:

```json
{
  "field_name": "title",
  "label": "Dataset Name",
  "preset": "title",
  "form_placeholder": "e.g. Health and Retirement Study"
},
{
  "field_name": "name",
  "label": "URL Slug",
  "preset": "dataset_slug",
  "form_placeholder": "e.g. health-retirement-study"
},
{
  "field_name": "notes",
  "label": "Description",
  "preset": "markdown"
},
{
  "field_name": "owner_org",
  "label": "Organization",
  "preset": "dataset_organization"
}
```

### Resource Fields

For resources, include at minimum:

```json
{
  "field_name": "url",
  "label": "URL",
  "preset": "resource_url_upload"
},
{
  "field_name": "name",
  "label": "Name",
  "form_placeholder": "eg. January 2011 Gold Prices"
},
{
  "field_name": "description",
  "label": "Description",
  "form_snippet": "markdown.html",
  "form_placeholder": "Some useful notes about the data"
},
{
  "field_name": "format",
  "label": "Format",
  "preset": "resource_format_autocomplete"
}
```

---

## Common Issues & Troubleshooting

### Issue 1: Schema File Not Found

**Error**: `FileNotFoundError` or schema not loading

**Solution**:
- Ensure the volume mount in docker-compose.dev.yml is correct
- Verify the file exists on your host machine
- Check that the path inside the container is correct using:
  ```bash
  docker-compose -f docker-compose.dev.yml exec ckan-dev ls -la /srv/app/schemas/
  ```

### Issue 2: Invalid Preset Error

**Error**: `SchemingException: preset 'preset_name' not defined`

**Common Invalid Presets**:
- ❌ `dataset_markdown` → ✅ Use `markdown` instead
- ❌ `resource_name_default` → ✅ Just use `form_snippet` directly
- ❌ `text` → ✅ Use `form_snippet: "text.html"` instead

**Solution**: Check the [official presets.json](https://github.com/ckan/ckanext-scheming/blob/master/ckanext/scheming/presets.json) for valid preset names.

### Issue 3: Path Format Error

**Error**: `ValueError: not enough values to unpack (expected 2, got 1)`

**Solution**: Use the `file://` prefix for absolute paths:
```bash
# ❌ Wrong:
CKAN__SCHEMING__DATASET_SCHEMAS="/srv/app/schemas/stockton_schema.json"

# ✅ Correct:
CKAN__SCHEMING__DATASET_SCHEMAS="file:///srv/app/schemas/stockton_schema.json"
```

### Issue 4: Changes Not Appearing

**Solution**:
1. Restart the container: `docker-compose -f docker-compose.dev.yml restart ckan-dev`
2. Clear your browser cache
3. Try accessing the form in an incognito window
4. Check logs for errors: `docker-compose -f docker-compose.dev.yml logs --tail=50 ckan-dev`

### Issue 5: Schema Validation Errors

**Solution**: Validate your JSON:
- Use a JSON validator (e.g., [jsonlint.com](https://jsonlint.com/))
- Check for:
  - Missing commas
  - Extra commas after last array item
  - Mismatched brackets
  - Unquoted keys or values

---

## Verification

### Step 1: Check Plugin Loading

Verify the plugin is loaded:

```bash
docker-compose -f docker-compose.dev.yml logs ckan-dev | grep -i scheming
```

You should see output like:
```
Loading the following plugins: ... scheming_datasets
```

### Step 2: Check Schema via API

Test if your schema is loaded using the CKAN API:

```bash
curl http://localhost:5001/api/3/action/scheming_dataset_schema_show?type=dataset
```

You should receive a JSON response with your schema definition.

### Step 3: Test in Web Interface

1. Navigate to http://localhost:5001/dataset/new
2. You should see all your custom fields in the dataset creation form
3. Test creating a dataset with your custom fields
4. Verify the fields display correctly on the dataset page

### Step 4: Check Configuration in Container

Verify the schema path is set correctly:

```bash
docker-compose -f docker-compose.dev.yml exec ckan-dev env | grep SCHEMING
```

Expected output:
```
CKAN__SCHEMING__DATASET_SCHEMAS=file:///srv/app/schemas/stockton_schema.json
```

---

## Example Schema

Here's a complete working example schema (Stockton University Custom Schema):

```json
{
  "scheming_version": 1,
  "dataset_type": "dataset",
  "about": "Stockton University Custom Schema",
  "about_url": "http://github.com/ckan/ckanext-scheming",
  "dataset_fields": [
    {
      "field_name": "title",
      "label": "Dataset Name",
      "preset": "title",
      "form_placeholder": "e.g. Health and Retirement Study"
    },
    {
      "field_name": "name",
      "label": "URL Slug",
      "preset": "dataset_slug",
      "form_placeholder": "e.g. health-retirement-study"
    },
    {
      "field_name": "notes",
      "label": "Short Description",
      "form_placeholder": "A brief summary of the dataset's purpose...",
      "preset": "markdown"
    },
    {
      "field_name": "impact_factor",
      "label": "Impact Factor",
      "form_snippet": "text.html",
      "display_snippet": "text.html",
      "form_placeholder": "e.g. 20.5"
    },
    {
      "field_name": "date_founded",
      "label": "Date Founded",
      "preset": "date",
      "help_text": "The year the dataset was established."
    },
    {
      "field_name": "number_of_participants",
      "label": "Number of Participants",
      "form_snippet": "text.html",
      "display_snippet": "text.html",
      "form_placeholder": "e.g. 1500"
    },
    {
      "field_name": "age_range",
      "label": "Age Range",
      "form_snippet": "text.html",
      "display_snippet": "text.html",
      "form_placeholder": "e.g. 65-85"
    },
    {
      "field_name": "domain_name",
      "label": "Content Domain",
      "preset": "select",
      "choices": [
        { "value": "mental_health", "label": "Mental Health" },
        { "value": "cognitive_training", "label": "Cognitive Training" },
        { "value": "financial_knowledge", "label": "Financial Knowledge" }
      ]
    },
    {
      "field_name": "owner_org",
      "label": "Organization",
      "preset": "dataset_organization"
    }
  ],
  "resource_fields": [
    {
      "field_name": "url",
      "label": "URL",
      "preset": "resource_url_upload"
    },
    {
      "field_name": "name",
      "label": "Name",
      "form_placeholder": "eg. January 2011 Gold Prices"
    },
    {
      "field_name": "description",
      "label": "Description",
      "form_snippet": "markdown.html",
      "form_placeholder": "Some useful notes about the data"
    },
    {
      "field_name": "format",
      "label": "Format",
      "preset": "resource_format_autocomplete"
    }
  ]
}
```

### Custom Fields in This Example

- **Impact Factor**: Text field for numerical impact metrics
- **Date Founded**: Date picker for when the dataset was created
- **Number of Participants**: Text field for study participant count
- **Age Range**: Text field for demographic information
- **Content Domain**: Dropdown menu with predefined research domains

---

## Additional Resources

### Official Documentation

- [ckanext-scheming GitHub](https://github.com/ckan/ckanext-scheming)
- [CKAN Extension Documentation](https://docs.ckan.org/en/latest/extensions/index.html)
- [CKAN API Guide](https://docs.ckan.org/en/latest/api/index.html)

### Preset Reference

View all available presets in the [presets.json](https://github.com/ckan/ckanext-scheming/blob/master/ckanext/scheming/presets.json) file.

### Example Schemas

Browse example schemas in the [ckanext-scheming repository](https://github.com/ckan/ckanext-scheming/tree/master/ckanext/scheming):
- `codelist.json` - Example with code lists
- `custom_org_with_address.json` - Organization schema example
- `group_with_bookface.json` - Group schema example

### Validators Reference

CKAN provides many built-in validators. See the [CKAN validators documentation](https://docs.ckan.org/en/latest/extensions/validators.html) for:
- `ignore_missing` - Field is optional
- `not_empty` - Field is required
- `int_validator` - Must be an integer
- `boolean_validator` - Must be true/false
- `url_validator` - Must be a valid URL
- `isodate` - Must be ISO date format

### Environment Variables (ckanext-envvars)

The `envvars` plugin allows configuration via environment variables:
- Dots (.) become double underscores (__)
- Format: `CKAN__SECTION__KEY=value`
- Example: `ckan.site_title` → `CKAN__SITE_TITLE`
- Example: `scheming.dataset_schemas` → `CKAN__SCHEMING__DATASET_SCHEMAS`

---

## Quick Start Checklist

- [ ] Add extension to [ckan/Dockerfile.dev](ckan/Dockerfile.dev)
- [ ] Rebuild Docker image
- [ ] Add `scheming_datasets` to `CKAN__PLUGINS` in [.env](.env)
- [ ] Set `CKAN__SCHEMING__DATASET_SCHEMAS` with `file://` prefix in [.env](.env)
- [ ] Add schema path to docker-compose.dev.yml environment
- [ ] Mount schema file in docker-compose.dev.yml volumes
- [ ] Create your custom schema JSON file
- [ ] Restart CKAN container
- [ ] Verify plugin loading in logs
- [ ] Test schema via API
- [ ] Create a test dataset with custom fields

---

## Support

If you encounter issues not covered in this guide:

1. Check CKAN logs: `docker-compose -f docker-compose.dev.yml logs --tail=100 ckan-dev`
2. Validate your JSON schema syntax
3. Review the [ckanext-scheming issues](https://github.com/ckan/ckanext-scheming/issues)
4. Consult the [CKAN community forums](https://discuss.ckan.org/)

---

**Last Updated**: December 2025
**CKAN Version**: 2.10.0
**ckanext-scheming Version**: master branch
