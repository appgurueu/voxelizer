import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.Color;
import java.io.File;
import java.io.IOException;

public class LogoCreator {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Error : Output and input path need to be given.");
            System.exit(1);
        } else {
            File in = new File(args[0]);
            File out = new File(args[1]);
            int scale = args.length >=3 ? Integer.parseInt(args[2]) : 3;
            if (!in.exists() || !in.canRead()) {
                System.out.println("Error : Input file doesn't exist or can't be read.");
                System.exit(1);
            }
            try {
                BufferedImage input = ImageIO.read(in);
                BufferedImage output = new BufferedImage(input.getWidth() * scale, input.getHeight() * scale, BufferedImage.TYPE_INT_ARGB);
                for (int x = 0; x < input.getWidth(); x++) {
                    for (int y = 0; y < input.getHeight(); y++) {
                        int c = input.getRGB(x, y);
                        for (int x_2 = x * scale + 1; x_2 < x * scale + scale - 1; x_2++) {
                            for (int y_2 = y * scale + 1; y_2 < y * scale + scale - 1; y_2++) {
                                output.setRGB(x_2, y_2, c);
                            }
                        }
                        int b = new Color(c, true).brighter().getRGB();
                        for (int x_2 = 0; x_2 < scale; x_2 += scale-1) {
                            for (int y_2 = 0; y_2 < scale; y_2++) {
                                output.setRGB(x_2 + x*scale, y_2 + y*scale, b);
                                output.setRGB(y_2 + x*scale, x_2 + y*scale, b);
                            }
                        }
                    }
                }
                ImageIO.write(output, "PNG", out);
                System.out.println("Texture created successfully.");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
