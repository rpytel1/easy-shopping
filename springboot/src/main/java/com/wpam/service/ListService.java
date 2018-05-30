package com.wpam.service;


import com.wpam.model.ListEntry;
import com.wpam.repository.ListRepository;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.FileEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.File;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

@Service
public class ListService {
    @Autowired
    private ListRepository listRepository;

    private static final String subscriptionKey = "814a10c0d4b5460da063276dc01e3d1b";


    private static final String uriBase =
            "https://westcentralus.api.cognitive.microsoft.com/vision/v2.0/recognizeText";


    public ListEntry addList(ListEntry listEntry) {
        return listRepository.addProduct(listEntry);
    }

    public ListEntry deleteList(ListEntry listEntry) {
        return listRepository.deleteProduct(listEntry);
    }

    public List<ListEntry> getWholeList(String owner) {
        return listRepository.getWholeList(owner);
    }

    public boolean sendList(String sender, String receiver) {
        return listRepository.sendList(sender, receiver);
    }

    public List<String> getEncodedList(File file) {
        System.out.println("recived data");
        List<String> list = new ArrayList<String>();
        CloseableHttpClient httpTextClient = HttpClientBuilder.create().build();
        CloseableHttpClient httpResultClient = HttpClientBuilder.create().build();
        ;

        try {
            // This operation requires two REST API calls. One to submit the image
            // for processing, the other to retrieve the text found in the image.

            URIBuilder builder = new URIBuilder(uriBase);

            // Request parameter.
            // Note: The request parameter changed for APIv2.
            // For APIv1, it is "handwriting", "true".
            builder.setParameter("mode", "Handwritten");

            // Prepare the URI for the REST API call.
            URI uri = builder.build();
            HttpPost request = new HttpPost(uri);

            // Request headers.
            request.setHeader("Content-Type", "application/octet-stream");
            request.setHeader("Ocp-Apim-Subscription-Key", subscriptionKey);

            // Request body.

            FileEntity reqEntity = new FileEntity(file);
            request.setEntity(reqEntity);

            // Make the first REST API call to detect the text.
            HttpResponse response = httpTextClient.execute(request);

            // Check for success.
            if (response.getStatusLine().getStatusCode() != 202) {
                // Format and display the JSON error message.
                HttpEntity entity = response.getEntity();
                String jsonString = EntityUtils.toString(entity);
                JSONObject json = new JSONObject(jsonString);
                System.out.println("Error:\n");
                System.out.println(json.toString(2));
                return list;
            }

            // Stores the URI where you can get the text recognition operation result.
            String operationLocation = null;

            // 'Operation-Location' in the response contains the URI to
            // retrieve the recognized text.
            Header[] responseHeaders = response.getAllHeaders();
            for (Header header : responseHeaders) {
                if (header.getName().equals("Operation-Location")) {
                    operationLocation = header.getValue();
                    break;
                }
            }

            if (operationLocation == null) {
                System.out.println("\nError retrieving Operation-Location.\nExiting.");
                System.exit(1);
            }

            // Note: The response may not be immediately available. Handwriting
            // recognition is an asynchronous operation, which takes a variable
            // amount of time dependent on the length of the text analyzed. You
            // may need to wait or retry the Get operation.


            Thread.sleep(500);

            // Make the second REST API call and get the response.
            HttpGet resultRequest = new HttpGet(operationLocation);
            resultRequest.setHeader("Ocp-Apim-Subscription-Key", subscriptionKey);

            HttpResponse resultResponse = httpResultClient.execute(resultRequest);
            HttpEntity responseEntity = resultResponse.getEntity();

            if (responseEntity != null) {
                // Format and display the JSON response.
                String jsonString = EntityUtils.toString(responseEntity);
                JSONObject json = new JSONObject(jsonString);

                JSONArray jsonArray = json.getJSONObject("recognitionResult").getJSONArray("lines");
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONArray jsonArrayWords = jsonArray.getJSONObject(i).getJSONArray("words");
                    for (int j = 0; j < jsonArrayWords.length(); j++) {
                        JSONObject jsonObject = jsonArrayWords.getJSONObject(j);
                        list.add(jsonObject.getString("text").toLowerCase());
                    }
                }


            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return list;

    }
}

