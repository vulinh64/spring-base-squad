import module java.xml;

void main() {

  try {
    var factory = DocumentBuilderFactory.newInstance();

    factory.setNamespaceAware(true);

    // Secure XML parsing (prevent XXE)
    factory.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
    factory.setXIncludeAware(false);
    factory.setExpandEntityReferences(false);

    var document = factory.newDocumentBuilder().parse(new File("pom.xml"));

    var namespace = document.getDocumentElement().getNamespaceURI();

    var parents = document.getElementsByTagNameNS(namespace, "parent");

    if (parents.getLength() == 0) {
      throw new IllegalStateException("Parent section not found");
    }

    if (!(parents.item(0) instanceof Element parent)) {
      throw new IllegalStateException("Invalid element");
    }

    var versions = parent.getElementsByTagNameNS(namespace, "version");

    if (versions.getLength() == 0) {
      throw new IllegalStateException("Parent version not found");
    }

    var version = versions.item(0).getTextContent().trim();

    if (version.isEmpty()) {
      throw new IllegalStateException("Parent version is empty");
    }

    IO.println(version);
  } catch (Exception e) {
    System.err.println("ERROR: %s".formatted(e.getMessage()));
    System.exit(1);
  }
}
