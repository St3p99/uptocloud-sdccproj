package unical.dimes.uptocloud.support;


import lombok.experimental.UtilityClass;

import java.text.Normalizer;

@UtilityClass
public class Utils {

    public static String removeSpecialChar(String src) {
        return Normalizer
                .normalize(src, Normalizer.Form.NFD)
                .replaceAll("[^\\p{ASCII}]", "")
                .replaceAll("[^a-zA-Z0-9]", " ").trim();
    }
}
