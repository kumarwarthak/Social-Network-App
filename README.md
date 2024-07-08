# samvada

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
using System;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using Microsoft.SqlServer.Dts.Runtime;
using Newtonsoft.Json.Linq;

public void Main()
{
    string clientId = "your_client_id";
    string clientSecret = "your_client_secret";
    string tenantId = "your_tenant_id";
    string siteUrl = "https://your_sharepoint_site";
    string uploadUrl = $"{siteUrl}/_api/web/GetFolderByServerRelativeUrl('/Shared Documents')/Files/add(url='your_file.txt',overwrite=true)";
    string filePath = "C:\\path_to_your_file.txt";

    string token = GetAccessToken(clientId, clientSecret, tenantId, siteUrl).Result;
    UploadFile(uploadUrl, filePath, token).Wait();

    Dts.TaskResult = (int)ScriptResults.Success;
}

private async Task<string> GetAccessToken(string clientId, string clientSecret, string tenantId, string siteUrl)
{
    using (var client = new HttpClient())
    {
        var tokenEndpoint = $"https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token";
        var body = $"client_id={clientId}&client_secret={clientSecret}&scope={siteUrl}/.default&grant_type=client_credentials";
        var content = new StringContent(body, System.Text.Encoding.UTF8, "application/x-www-form-urlencoded");

        var response = await client.PostAsync(tokenEndpoint, content);
        var responseContent = await response.Content.ReadAsStringAsync();
        var token = JObject.Parse(responseContent)["access_token"].ToString();

        return token;
    }
}

private async Task UploadFile(string uploadUrl, string filePath, string token)
{
    using (var client = new HttpClient())
    {
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        var fileContent = new ByteArrayContent(File.ReadAllBytes(filePath));
        fileContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

        var response = await client.PostAsync(uploadUrl, fileContent);
        response.EnsureSuccessStatusCode();
    }
}
