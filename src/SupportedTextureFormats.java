import javax.imageio.ImageIO;

public class SupportedTextureFormats {
    public static void main(String... args) {
        System.out.println("The supported image file formats are : "+String.join(", ", ImageIO.getReaderFormatNames()));
    }
}