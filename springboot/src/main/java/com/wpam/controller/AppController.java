package com.wpam.controller;

import com.wpam.model.ListEntry;
import com.wpam.service.ListService;
import com.wpam.service.LoginService;
import org.apache.tomcat.util.codec.binary.Base64;
import org.apache.tomcat.util.http.fileupload.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import com.wpam.model.User;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.websocket.server.PathParam;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
public class AppController {
    @Autowired
    private LoginService loginService;
    @Autowired
    private ListService listService;

    @RequestMapping(value = "/sayHello", method = RequestMethod.GET)
    public String sayHello() {
        return "Hello";
    }

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public boolean checkLogin(@RequestBody User user, @RequestHeader MultiValueMap<String, String> headers) {
        return loginService.loginUser(user);
    }

    @RequestMapping(value = "/addProduct", method = RequestMethod.POST)
    public ListEntry addProduct(@RequestBody ListEntry listEntry, @RequestHeader MultiValueMap<String, String> headers) {
        return listService.addList(listEntry);
    }

    @RequestMapping(value = "/addProducts", method = RequestMethod.POST)
    public List<ListEntry> addProducts(@RequestBody List<ListEntry> listEntries, @RequestHeader MultiValueMap<String, String> headers) {
        for(ListEntry listEntry : listEntries) {
            listService.addList(listEntry);
        }
        return listEntries;
    }

    @RequestMapping(value = "/deleteProduct", method = RequestMethod.POST)
    public ListEntry deleteProduct(@RequestBody ListEntry listEntry, @RequestHeader MultiValueMap<String, String> headers) {
        return listService.deleteList(listEntry);
    }

    @RequestMapping(value = "/getWholeList/{owner}", method = RequestMethod.GET)
    public List<ListEntry> getWholeList(@PathVariable("owner") String owner, @RequestHeader MultiValueMap<String, String> headers) {
        return listService.getWholeList(owner);
    }

    @RequestMapping(value = "/getAllUser", method = RequestMethod.GET)
    public List<String> getAllUser(@RequestHeader MultiValueMap<String, String> headers) {
        return loginService.getAllUsers();
    }

    @RequestMapping(value = "/sendList", method = RequestMethod.POST)
    public boolean sendList(@RequestBody Map<String, String> payload, @RequestHeader MultiValueMap<String, String> headers) {
        System.out.println(payload);
        return listService.sendList(payload.get("sender"), payload.get("receiver"));
    }

    @RequestMapping(value="/upload",method = RequestMethod.POST)
    public @ResponseBody List<String> uploadImage2(@RequestParam("image") String imageValue,HttpServletRequest request)
    {
        List list = new ArrayList<String>();
        try
        {
            //This will decode the String which is encoded by using Base64 class
            byte[] imageByte= Base64.decodeBase64(imageValue.replaceAll(" ","+"));
            FileOutputStream stream = new FileOutputStream("/Users/rafalpytel/Downloads/springboot/text.jpeg");
            try {
                stream.write(imageByte);
                File file = new File("/Users/rafalpytel/Downloads/springboot/text.jpeg");
                list=listService.getEncodedList(file);
            }catch(Exception e) {
                e.printStackTrace();
            }
            finally
            {
                stream.close();
            }
        }
        catch(Exception e)
        {
             e.printStackTrace();
        }
        System.out.println(list);
        return list;
    }
}

